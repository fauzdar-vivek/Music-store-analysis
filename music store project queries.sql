--Displaying sale of music tracks in each country (countries with most invoices)
select count(*) as c,billing_country
from invoice
group by billing_country
order by c desc
limit 5
------------------------------------------------------------------------------------------------


--looking at cities with most customers.
select billing_city, sum(total) as invoice_total
from invoice
group by billing_city
order by invoice_total desc
------------------------------------------------------------------------------------------------


--showing customer details with most invoices(best customer)
select c.customer_id, c.first_name, c.last_name, sum(i.total) as tt
from customer c
join invoice i
on c.customer_id = i.customer_id
group by c.customer_id
order by tt desc
limit 1
-------------------------------------------------------------------------------------------------


--
select distinct email, first_name, last_name
from customer c
join invoice i on c.customer_id= i.customer_id
join invoice_line il on i.invoice_id= il.invoice_id
join track tr on tr.track_id= il.track_id
join genre g on g.genre_id=tr.genre_id
where g.name like 'Rock'
order by email
-------------------------------------------------------------------------------------------------



--showing artist details with their total tracks of rock genre
select ar.artist_id, ar.name, count(ar.artist_id) as co
from track tr
join album ab on ab.album_id= tr.album_id
join artist ar on ar.artist_id = ab.artist_id
join genre g on g.genre_id= tr.genre_id
where g.name like 'Rock'
group by ar.artist_id
order by co desc 
limit 10
---------------------------------------------------------------------------------------------------



--showing the track details of songs that have length more than the average length of all songs
select name, milliseconds
from track 
where milliseconds> 
(
select avg(milliseconds) as av
	from track
)
order by milliseconds desc
---------------------------------------------------------------------------------------------------



--showing the list of total amount spent by each customer on artists. List contains customer name, artist name and total amount spent.
with bsa as
(
select ar.artist_id, ar.name as artist_name, sum(il.unit_price*il.quantity) as tt
from invoice_line il
join track tr on tr.track_id=il.track_id
join album ab on ab.album_id = tr.album_id
join artist ar on ar.artist_id = ab.artist_id
group by 1
order by 3 desc
limit 1
)

select c.customer_id, c.first_name, c.last_name, bsa.artist_name, count(bsa.artist_name) as number_of_songs,
sum(il.unit_price*il.quantity) as spent
from invoice i
join customer c on i.customer_id = c.customer_id
join invoice_line il on il.invoice_id= i.invoice_id
join track tr on tr.track_id=il.track_id
join album ab on ab.album_id = tr.album_id
join bsa on bsa.artist_id=ab.artist_id
   group by 1,2,3,4
   order by spent desc
-----------------------------------------------------------------------------------------------------



--Analyzing the most popular genre for each country i.e; genre with the highest amount of purchases in each country.
with popular_genre as
(
select count(il.quantity) as purchases, i.billing_country, g.name, g.genre_id,
row_number() over(partition by i.billing_country order by count(il.quantity) desc) as row_no
from invoice_line il
join invoice i on i.invoice_id= il.invoice_id
join track tr on tr.track_id= il.track_id
join genre g on g.genre_id=tr.genre_id
group by 2,3,4
order by purchases desc 
)

select * from popular_genre where row_no =1
-----------------------------------------------------------------------------------------------------



--Determining the customers details of top customer of each country along with the total amount spent by those customers.
with top_customer as
(
select c.customer_id, c.first_name, c.last_name, i.billing_country, sum(i.total) as tt,
row_number() over (partition by i.billing_country order by count(c.customer_id)) as row_no
from customer c
join invoice i on i.customer_id=c.customer_id
group by 1,4
order by 4
)
select * from top_customer where row_no=1
-----------------------------------------------------------------------------------------------------


