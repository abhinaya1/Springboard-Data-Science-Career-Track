/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: 
Password: 

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT name
FROM Facilities
WHERE membercost <>0

/* Q2: How many facilities do not charge a fee to members? */
SELECT count( DISTINCT name )
FROM Facilities
WHERE membercost =0

4 FACILIITES DO NOT CHARGE A FEE TO MEMBERS

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid,name, membercost, monthlymaintenance 
FROM Facilities 
WHERE membercost <> 0 
	AND membercost < .20*monthlymaintenance

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT *
FROM Facilities
WHERE facid
IN ( 1, 5 )

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance <100
THEN 'cheap'
ELSE 'expesnive'
END AS label
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT surname, firstname
FROM Members
WHERE joindate = (
SELECT MAX( joindate )
FROM Members )

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT
    f.name AS court_name,
    CONCAT_WS(SPACE(1), m.firstname,' ',m.surname) AS member_name
FROM Bookings b
JOIN
    Facilities f ON b.facid = f.facid
JOIN
    Members m ON b.memid = m.memid
WHERE
    f.name LIKE 'Tennis Court%' 
ORDER BY
    member_name;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name, CONCAT_WS(SPACE(1), m.firstname,' ',m.surname) AS member_name, 
CASE
    WHEN b.memid = 0  THEN b.slots*f.guestcost
    ELSE b.slots*f.membercost
END AS cost
FROM Bookings b
JOIN
    Facilities f ON b.facid = f.facid
JOIN
    Members m ON b.memid = m.memid
WHERE
    DATE(b.starttime) = '2012-09-14' 
    AND (
    (b.memid = 0 AND (b.slots * f.guestcost) > 30)
    OR
    (b.memid <> 0 AND (b.slots * f.membercost) > 30)
  )
ORDER BY cost DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT sub.name, sub.member_name,sub.cost
FROM (
SELECT f.name, CONCAT_WS(SPACE(1), m.firstname,' ',m.surname) AS member_name, b.starttime,
CASE
    WHEN b.memid = 0  THEN b.slots*f.guestcost
    ELSE b.slots*f.membercost
END AS cost
FROM Bookings b
JOIN
    Facilities f ON b.facid = f.facid
JOIN
    Members m ON b.memid = m.memid
) AS sub

WHERE
    DATE(sub.starttime) = '2012-09-14' 
    AND sub.cost > 30
ORDER BY sub.cost DESC;

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT sub.name, sum(sub.cost) AS total_revenue
FROM (
SELECT f.name, 
CASE
    WHEN b.memid = 0  THEN b.slots*f.guestcost
    ELSE b.slots*f.membercost
END AS cost
FROM Bookings b
JOIN
    Facilities f ON b.facid = f.facid
JOIN
    Members m ON b.memid = m.memid
) AS sub
GROUP BY sub.name
HAVING total_revenue > 1000
ORDER BY total_revenue DESC;

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT 
  m.surname AS member_surname,
  m.firstname AS member_firstname,
  r.surname AS recommender_surname,
  r.firstname AS recommender_firstname  
FROM Members m
LEFT JOIN Members r ON m.recommendedby = r.memid
ORDER BY m.surname ASC, m.firstname ASC;

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT f.name as Facility, sum(b.slots) as total_usage_by_member
FROM Bookings b
JOIN Facilities f
ON b.facid = f.facid
WHERE b.memid <> 0
GROUP BY f.name
ORDER BY total_usage_by_member;

/* Q13: Find the facilities usage by month, but not guests */

SELECT f.name AS facility_name, MONTH(b.starttime) AS month, sum(b.slots) AS total_slots
FROM Bookings b
JOIN Facilities f
ON b.facid = f.facid
WHERE b.memid <> 0
GROUP BY f.name, month
ORDER BY total_slots;
