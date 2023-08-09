/*
	SQL Code Challenge
	Author: Jaime M. Shaker
	Email: jaime.m.shaker@gmail.com or jaime@shaker.dev
	Website: https://www.shaker.dev
	LinkedIn: https://www.linkedin.com/in/jaime-shaker/
	
*/


/* Question 2. 
 * 
 * List all of the regions and the total number of countries in each region.
 * 
 */

SELECT 
	initcap(region) AS region,
	count(*) AS country_count
FROM
	cleaned_data.countries
GROUP BY
	region
ORDER BY 
	country_count DESC;

/*

region   |country_count|
---------+-------------+
Africa   |           59|
Americas |           57|
Asia     |           50|
Europe   |           48|
Oceania  |           26|
Antartica|            1|

*/

/* Question 3. 
 * 
 * List all of the countries and the total number of cities in the Northern Europe sub-region.  
 * List the country names in uppercase and order the list by the length of the country name in ascending order.
 * 
 */

SELECT 
	upper(co.country_name) AS country_name,
	count(*) AS city_count
FROM
	cleaned_data.countries AS co
JOIN 
	cleaned_data.cities AS ci
ON 
	co.country_code_2 = ci.country_code_2
WHERE
	co.sub_region = 'northern europe'
GROUP BY 
	co.country_name
ORDER BY 
	length(co.country_name), co.country_name;

/*

country_name  |city_count|
--------------+----------+
JERSEY        |         1|
LATVIA        |        39|
NORWAY        |       127|
SWEDEN        |       148|
DENMARK       |        75|
ESTONIA       |        20|
FINLAND       |       142|
ICELAND       |        12|
IRELAND       |        64|
LITHUANIA     |        61|
ISLE OF MAN   |         2|
FAROE ISLANDS |        29|
UNITED KINGDOM|      1305|

*/
	
/* Question 4.
 * 
 * Repeat the query for question #3, but this time, order the results alphabetically by 
 * the **second** letter of the city name in ascending order and the number of cities 
 * in descending order.
 * 
 */ 

SELECT 
	upper(co.country_name) AS country_name,
	count(*) AS city_count
FROM
	cleaned_data.countries AS co
JOIN 
	cleaned_data.cities AS ci
ON 
	co.country_code_2 = ci.country_code_2
WHERE
	co.sub_region = 'northern europe'
GROUP BY 
	co.country_name
ORDER BY 
	substring(co.country_name,2,1) ASC, count(*) DESC;

/*

country_name  |city_count|
--------------+----------+
LATVIA        |        39|
FAROE ISLANDS |        29|
ICELAND       |        12|
DENMARK       |        75|
JERSEY        |         1|
FINLAND       |       142|
LITHUANIA     |        61|
UNITED KINGDOM|      1305|
NORWAY        |       127|
IRELAND       |        64|
ESTONIA       |        20|
ISLE OF MAN   |         2|
SWEDEN        |       148|

*/


/* Question 5.
 * 
 * List the country, city name, population and city name length for the city names that are palindromes in the 
 * Western Asia sub-region.  Format the population with a thousands separator (1,000) and format the length of 
 * the city name in roman numerals.  Order by the length of the city name in descending order and 
 * alphabetically in ascending order.
 * 
 */

SELECT 
	initcap(co.country_name) AS country_name,
	initcap(ci.city_name) AS city_name,
	to_char(ci.population, '999G999') AS population,
	to_char(length(ci.city_name), 'RN') AS roman_numeral_length
FROM
	cleaned_data.countries AS co
JOIN 
	cleaned_data.cities AS ci
ON 
	co.country_code_2 = ci.country_code_2
WHERE
	ci.city_name = reverse(ci.city_name)
AND
	co.sub_region = 'western asia'
ORDER BY 
	length(ci.city_name) DESC, ci.city_name ASC;

/*

country_name        |city_name|population|roman_numeral_length|
--------------------+---------+----------+--------------------+
Yemen               |Hajjah   |  46,568  |             VI     |
Syrian Arab Republic|Hamah    | 696,863  |              V     |
Turkey              |Kavak    |  21,692  |              V     |
Turkey              |Kinik    |  29,803  |              V     |
Turkey              |Tut      |  10,161  |            III     |

*/


/* Question 6.
 * 
 * List all of the countries that end in 'stan'.  Make your query case insensitive and list whether 
 * the total population of the cities listed is an odd or even number.
 * 
 */

SELECT
	country_name,
	to_char(sum(ci.population), '99G999G999') total_population,
	CASE
		WHEN (sum(ci.population) % 2) = 0
			THEN 'Even'
		ELSE 
			'Odd'
	END AS odd_or_even
FROM
	cleaned_data.countries AS co
JOIN 
	cleaned_data.cities AS ci
ON 
	co.country_code_2 = ci.country_code_2
WHERE
	country_name ILIKE '%stan'
GROUP BY
	country_name
ORDER BY 
	country_name;

/*

country_name|total_population|odd_or_even|
------------+----------------+-----------+
afghanistan | 10,327,017     |Odd        |
kazakhstan  | 11,794,851     |Odd        |
kyrgyzstan  |  3,139,850     |Even       |
pakistan    | 64,214,630     |Even       |
tajikistan  |  4,374,883     |Odd        |
turkmenistan|  2,697,719     |Odd        |
uzbekistan  | 11,569,471     |Odd        |

*/

/* Question 7.
 * 
 * List the third most populated city by region WITHOUT using limit or offset.
 * List the region name, city name and total population and order by region.
 * 
 */

WITH get_city_rank_cte AS (
	SELECT
		co.region,
		ci.city_name,
		ci.population AS third_largest_pop,
		DENSE_RANK() OVER (PARTITION BY co.region ORDER BY ci.population DESC) AS rnk
	FROM
		cleaned_data.countries AS co
	JOIN 
		cleaned_data.cities AS ci
	ON 
		co.country_code_2 = ci.country_code_2
	WHERE 
		ci.population IS NOT NULL
	GROUP BY
		co.region,
		ci.city_name,
		ci.population
)
SELECT
	initcap(region) AS region,
	initcap(city_name) AS city_name,
	to_char(third_largest_pop, '99G999G999') AS third_largest_pop
FROM
	get_city_rank_cte
WHERE
	rnk = 3;

/*

region  |city_name|third_largest_pop|
--------+---------+-----------------+
Africa  |Kinshasa | 12,836,000      |
Americas|New York | 18,972,871      |
Asia    |Delhi    | 32,226,000      |
Europe  |Paris    | 11,060,000      |
Oceania |Brisbane |  2,360,241      |

*/

/* Question 8.
 * 
 * List the third most populated city by region WITHOUT using limit or offset.
 * List the region name, city name and total population and order by region.
 * 
 */

WITH get_ntile_cte AS (
	SELECT 
		country_name,
		NTILE(3) OVER (ORDER BY country_name) AS nt
	FROM
		cleaned_data.countries AS co
	JOIN 
		cleaned_data.languages AS l
	ON
		co.country_code_2 = l.country_code_2
	WHERE
		sub_region = 'western asia'
	AND 
		l.language = 'arabic'
)
SELECT
	country_name
FROM
	get_ntile_cte
WHERE
	nt = 3;


/*

country_name        |
--------------------+
saudi arabia        |
syrian arab republic|
united arab emirates|
yemen               |

*/

/* Question 9.
 * 
 *  Create a query that lists country name, capital name, population, languages spoken 
 * 	and currency name for countries in the Northen Africa sub-region.  There can be multiple 
 * 	currency names and languages spoken per country.  Add multiple values for the same 
 * 	field into an array.
 * 
 */

WITH get_row_values AS (
	SELECT
		co.country_name,
		ci.city_name,
		ci.population,
		array_agg(l.LANGUAGE) AS language_array,
		cu.currency_name AS currency_array
	FROM
		cleaned_data.countries AS co
	JOIN
		cleaned_data.cities AS ci
	ON 
		co.country_code_2 = ci.country_code_2
	JOIN
		cleaned_data.languages AS l
	ON 
		co.country_code_2 = l.country_code_2
	JOIN
		cleaned_data.currencies AS cu
	ON 
		co.country_code_2 = cu.country_code_2
	WHERE
		sub_region = 'northern africa'
	AND
		ci.capital = TRUE
	GROUP BY
		co.country_name,
		ci.city_name,
		ci.population,
		cu.currency_name
)
SELECT
	*
FROM
	get_row_values;

/*

country_name|city_name|population|language_array                              |currency_array |
------------+---------+----------+--------------------------------------------+---------------+
algeria     |algiers  |   3415811|{french,arabic,kabyle}                      |algerian dinar |
egypt       |cairo    |  20296000|{arabic}                                    |egyptian pound |
libya       |tripoli  |   1293016|{arabic}                                    |libyan dinar   |
morocco     |rabat    |    572717|{arabic,tachelhit,moroccan tamazight,french}|moroccan dirham|
sudan       |khartoum |   7869000|{arabic,english}                            |sudanese pound |
tunisia     |tunis    |   1056247|{french,arabic}                             |tunisian dinar |

*/

