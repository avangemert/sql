-- Makes it so all of the following code will affect sakila database--
USE sakila;

-- Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM sakila.actor;

-- Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT upper(concat(first_name,' ',last_name)) as Actor_Name FROM actor;

-- You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
SELECT actor_id, first_name, last_name FROM sakila.actor
WHERE first_name = "Joe";

-- Find all actors whose last name contain the letters GEN:
SELECT * FROM sakila.actor
WHERE last_name LIKE '%GEN%';

-- Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name FROM sakila.actor 
WHERE last_name LIKE '%LI%' ;

-- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM sakila.country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE sakila.actor 
ADD COLUMN middle_name VARCHAR(45) NOT NULL AFTER first_name;

-- Change the data type of the middle_name column to blobs.
ALTER TABLE sakila.actor 
MODIFY COLUMN middle_name BLOB NOT NULL;

-- Delete the middle_name column.
ALTER TABLE actor
DROP COLUMN middle_name;

-- List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS 'Number_of_Actors'
FROM actor
GROUP BY last_name;

-- List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS 'Number_of_Actors'
FROM actor
GROUP BY last_name
HAVING Number_of_Actors > 1;

-- Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE actor_id = 172;

-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
UPDATE actor
SET first_name = "GROUCHO"
WHERE actor_id = 172;

-- You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
JOIN address ON
(staff.address_id = address.address_id);

-- Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment
SELECT staff.staff_id, SUM(payment.amount) AS 'August_2005_amount' 
FROM staff JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment.payment_date LIKE '2005-08%'
GROUP BY staff_id;

-- List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film_actor.film_id, COUNT(film_actor.actor_id) AS 'Number_of_Actors'
FROM film_actor INNER JOIN film ON film_actor.film_id = film.film_id
GROUP BY film_id;

-- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film_id, COUNT(inventory_id) AS 'Number_of_Copies'
FROM inventory
WHERE film_id = (SELECT film_id FROM film
WHERE title = "HUNCHBACK IMPOSSIBLE")
GROUP BY film_id;

-- Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name,  SUM(payment.amount) AS 'Total Amount Paid'
FROM payment JOIN customer ON payment.customer_id = customer.customer_id
GROUP BY last_name, first_name
ORDER BY last_name ASC;

-- The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title
from film_text
where film_id in 
(select film_id from film where title LIKE 'Q%' OR title like 'K%' AND language_id = 1);

-- Use subqueries to display all actors who appear in the film Alone Trip.
SELECT actor.first_name, actor.last_name
FROM actor
WHERE actor_id IN
(SELECT actor_id
FROM film_actor
WHERE film_id = (SELECT film_id FROM film WHERE title = "ALONE TRIP"));

-- You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers.
-- Use joins to retrieve this information.
select customer.first_name, customer.last_name, customer.email
from country
inner join city
on country.country_id=city.country_id 
inner join address
on address.city_id=city.city_id
inner join customer
on customer.address_id=address.address_id
where city.country_id = 20;

-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as famiy films.
select film.title
from category
inner join film_category
on category.category_id=film_category.category_id 
inner join film
on film.film_id=film_category.film_id
where category.name = "Family";

-- Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(film.title) AS 'Number_of_Rentals'
FROM rental
INNER JOIN inventory
ON inventory.inventory_id=rental.inventory_id
INNER JOIN film
ON film.film_id=inventory.film_id
GROUP BY title
ORDER BY Number_of_Rentals DESC;

-- Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, CONCAT('$', FORMAT(SUM(amount), 'C', 'en-US')) AS 'Revenue'
FROM store
INNER JOIN staff
ON store.store_id=staff.store_id
INNER JOIN rental
ON rental.staff_id = staff.staff_id
INNER JOIN payment
ON payment.rental_id=rental.rental_id
GROUP BY store_id;

-- Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM store
INNER JOIN address
ON store.address_id=address.address_id
INNER JOIN city
ON city.city_id=address.city_id
INNER JOIN country
ON country.country_id=city.country_id;

-- List the top five genres in gross revenue in descending order. 
SELECT category.name, SUM(payment.amount) AS 'Gross_Revenue'
FROM category
INNER JOIN film_category
ON category.category_id=film_category.category_id
INNER JOIN inventory
ON inventory.film_id=film_category.film_id
INNER JOIN rental
ON rental.inventory_id=inventory.inventory_id
INNER JOIN payment
ON payment.rental_id=rental.rental_id
GROUP BY category.name
ORDER BY Gross_Revenue DESC
LIMIT 5;

-- In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
SELECT category.name, SUM(payment.amount) AS 'Gross_Revenue'
FROM category
INNER JOIN film_category
ON category.category_id=film_category.category_id
INNER JOIN inventory
ON inventory.film_id=film_category.film_id
INNER JOIN rental
ON rental.inventory_id=inventory.inventory_id
INNER JOIN payment
ON payment.rental_id=rental.rental_id
GROUP BY category.name
ORDER BY Gross_Revenue DESC
LIMIT 5;

-- How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;







