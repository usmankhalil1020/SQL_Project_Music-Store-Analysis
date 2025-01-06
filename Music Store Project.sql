create database music_store;
use music_store;


-- Q1 Who is the senior most employee based on job title.
SELECT 
    *
FROM
    employee
ORDER BY levels DESC
LIMIT 1;

-- Q2 Which countries have the most invoices.
SELECT 
    COUNT(*) AS total_invoices, billing_country
FROM
    invoice
GROUP BY billing_country
ORDER BY total_invoices DESC;

-- Q3 What are top 3 values of total invoice.
SELECT 
    invoice_id, ROUND(total, 1)
FROM
    invoice
ORDER BY total DESC
LIMIT 3;

-- Q4 Which city has the best customers? we would like to throw a professional Music Festival in the city we made the most money.
-- Write a query that returns one city that has the highest sum of invoice totals. Returns both the city name & sum of all invoice totals.
SELECT 
    billing_city, SUM(total) AS invoice_total
FROM
    invoice
GROUP BY billing_city
ORDER BY invoice_total DESC;

-- Q5 Who is the best customer? the customer who has spent the most money will be declared the best customer.
-- Write a query that returns the person who has spent the most money.

SELECT 
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    SUM(invoice.total) AS total
FROM
    customer
        JOIN
    invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id , customer.first_name , customer.last_name
ORDER BY total DESC
LIMIT 1;

-- Q6 Write query to return the email, first name, last name and genre of all Rock Music listeners.
-- Return your list ordered alphabetically by email starting with A.
SELECT DISTINCT customer.email, customer.first_name, customer.last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE invoice_line.track_id IN (
    SELECT track.track_id 
    FROM track
    JOIN genre ON track.genre_id = genre.genre_id
    WHERE genre.name = 'Rock'
)
ORDER BY customer.email;

-- Q7 Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total
-- track count of the top 10 rock bands.
SELECT 
    artist.artist_id,
    artist.name,
    COUNT(artist.artist_id) AS no_of_songs
FROM
    track
        JOIN
    album2 ON album2.album_id = track.album_id
        JOIN
    artist ON artist.artist_id = album2.artist_id
        JOIN
    genre ON genre.genre_id = track.genre_id
WHERE
    genre.name LIKE 'Rock'
GROUP BY artist.artist_id , artist.name
ORDER BY no_of_songs DESC
LIMIT 10;

-- Q8 Return all the track names that have a song length longer than the average song length. Returns and Milliseconds for each track.
-- Order by the song length with the longest songs listed first.
SELECT 
    name, milliseconds
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds) AS avg_track_length
        FROM
            track)
ORDER BY milliseconds DESC;

-- Q9 Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent.
WITH best_selling_artist AS (
    SELECT 
        artist.artist_id AS artist_id, 
        artist.name AS artist_name,
        SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales 
    FROM invoice_line 
    JOIN track ON track.track_id = invoice_line.track_id 
    JOIN album2 ON album2.album_id = track.album_id 
    JOIN artist ON artist.artist_id = album2.artist_id 
    GROUP BY artist_id, artist_name 
    ORDER BY total_sales DESC 
    LIMIT 1
)
SELECT 
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    bsa.artist_name,
    SUM(invoice_line.unit_price * invoice_line.quantity) AS amount_spent
FROM
    invoice
        JOIN
    customer ON customer.customer_id = invoice.customer_id
        JOIN
    invoice_line ON invoice_line.invoice_id = invoice.invoice_id
        JOIN
    track ON track.track_id = invoice_line.track_id
        JOIN
    album2 ON album2.album_id = track.album_id
        JOIN
    best_selling_artist bsa ON bsa.artist_id = album2.artist_id
GROUP BY customer.customer_id , customer.first_name , customer.last_name , bsa.artist_name
ORDER BY amount_spent DESC;

-- Q10 We want to find out the most popular music genre for each country.
-- We determine the most popular genre as the genre with the highest amount of purchase.
with popular_genre as (
select count(invoice_line.quantity) as purchase, customer.country,
genre.name, genre.genre_id,
row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as rowno 
from invoice_line join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id group by customer.country, genre.name, genre.genre_id
order by purchase desc
)
select * from popular_genre where rowno <= 1;


-- Q11 Write a query that determines the customer that has spent the most on music for each country.
-- Write a query that returns the country along with the top customer and how much they spent.
-- For countries where the top amount spent is shared. Provide all customers who spent this amount
with customer_with_country as (
select customer.customer_id, first_name, last_name, billing_country,
sum(total) as total_spending,
row_number() over(partition by billing_country order by sum(total) desc) as RowNo 
from invoice
join customer on customer.customer_id = invoice.customer_id
group by customer.customer_id, first_name,
last_name, billing_country order by total_spending desc
)
select * from customer_with_country where RowNo <= 1;














































































































