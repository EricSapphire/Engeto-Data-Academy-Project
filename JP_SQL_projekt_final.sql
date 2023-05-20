#dotazy k prozkoumání datasetů
SELECT *
FROM czechia_payroll_industry_branch cpib;

SELECT *
FROM czechia_payroll_calculation;

SELECT *
FROM czechia_payroll_unit cpu;

SELECT *
FROM czechia_payroll_value_type cpvt;

SELECT *
FROM czechia_payroll cp;

#pomocná tabulka 1
SELECT *,
	avg(cp.value) AS average_salary
FROM czechia_payroll cp
JOIN czechia_payroll_industry_branch cpib
ON cp.industry_branch_code = cpib.code
WHERE value_type_code = "5958"
GROUP BY payroll_year, industry_branch_code
ORDER BY industry_branch_code, payroll_year;

#dotazy k prozkoumání datasetů navázaných na czechia_price

SELECT *
FROM czechia_price cp;

SELECT *
FROM czechia_price_category cpc;

SELECT *
FROM czechia_region cr;

#pomocná tabulka 2
SELECT *
FROM czechia_price cpr
JOIN czechia_price_category cpc
ON cpr.category_code = cpc.code
WHERE region_code IS NULL;

#primární tabulka s daty
CREATE TABLE t_jan_prudek_project_sql_primary_final (
SELECT *
FROM (
SELECT cp.value AS salary, cp.industry_branch_code, cp.payroll_year, cpib.name AS industry_name,
	avg(cp.value) AS average_salary
FROM czechia_payroll cp
JOIN czechia_payroll_industry_branch cpib
ON cp.industry_branch_code = cpib.code
WHERE value_type_code = "5958"
GROUP BY payroll_year, industry_branch_code
ORDER BY industry_branch_code, payroll_year) AS payt
JOIN (
SELECT *
FROM czechia_price cpr
JOIN czechia_price_category cpc
ON cpr.category_code = cpc.code
WHERE region_code IS NULL) AS prt
ON payt.payroll_year = YEAR(prt.date_from)
);

#sekundární tabulka s daty
CREATE TABLE t_Jan_Prudek_project_SQL_secondary_final (
SELECT c.country, e.gdp, e.gini, e.`year`, c.continent
FROM economies e
JOIN countries c
ON e.country=c.country
WHERE c.continent = 'Europe'
HAVING e.`year` > 1999
ORDER BY
	c.country ASC, e.`year` ASC
);

SELECT * FROM t_jan_prudek_project_sql_primary_final
GROUP BY industry_branch_code, payroll_year;

#tabulka odvětví, kdy mzdy klesaly
SELECT t.industry_branch_code, t.industry_name, t.payroll_year, t2.payroll_year + 1 AS payroll_year_prev,
	round ((t.salary - t2.salary) / t2.salary * 100, 2) AS salary_growth
FROM (SELECT * FROM t_jan_prudek_project_sql_primary_final
GROUP BY industry_branch_code, payroll_year) as t
JOIN (SELECT * FROM t_jan_prudek_project_sql_primary_final
GROUP BY industry_branch_code, payroll_year) t2
ON t.industry_branch_code = t2.industry_branch_code
AND t.payroll_year = t2.payroll_year + 1
WHERE round ((t.salary - t2.salary) / t2.salary * 100, 2) < 0
ORDER BY t.industry_branch_code, payroll_year ASC;

#množství mléka a chleba z mzdu v daném roce
SELECT payroll_year, name, floor(avg(average_salary/value))
FROM t_jan_prudek_project_sql_primary_final
WHERE (payroll_year = (SELECT max(payroll_year) FROM t_jan_prudek_project_sql_primary_final))
	AND (name LIKE 'mléko%' OR name LIKE 'chléb%')
GROUP BY name, payroll_year
UNION ALL
SELECT payroll_year, name, floor(avg(average_salary/value))
FROM t_jan_prudek_project_sql_primary_final
WHERE (payroll_year = (SELECT min(payroll_year) FROM t_jan_prudek_project_sql_primary_final))
	AND (name LIKE 'mléko%' OR name LIKE 'chléb%')
GROUP BY name, payroll_year
ORDER BY payroll_year;


SELECT name, value FROM t_jan_prudek_project_sql_primary_final
WHERE payroll_year = 2014
	AND name LIKE 'banán%'
UNION
SELECT name, value FROM t_jan_prudek_project_sql_primary_final
WHERE payroll_year = 2015
	AND name LIKE 'banán%';

#nejpomaleji zdražující potravina
SELECT t.name, t.payroll_year, t2.payroll_year + 1 AS year_prev,
	round((t.value-t2.value) / t2.value * 100, 2) AS food_price_growth 
FROM (SELECT * FROM t_jan_prudek_project_sql_primary_final
GROUP BY name, payroll_year) t
JOIN (SELECT * FROM t_jan_prudek_project_sql_primary_final
GROUP BY name, payroll_year) t2
	ON  t.payroll_year = t2.payroll_year + 1
	AND t.name = t2.name
	AND t.payroll_year < 2018
ORDER BY food_price_growth;

#testovací tabulka porovnání růtu mezd a cen 1
SELECT tab1.payroll_year,
	round(avg(tab1.food_price_growth), 2) AS avg_food_price_growth,
	round(avg(tab2.salary_growth),2) AS avg_salary growth
FROM (SELECT t.industry_branch_code, t.industry_name, t.payroll_year, t2.payroll_year + 1 AS payroll_year_prev,
	round ((t.salary - t2.salary) / t2.salary * 100, 2) AS salary_growth
FROM (SELECT * FROM t_jan_prudek_project_sql_primary_final
GROUP BY industry_branch_code, payroll_year) as t
JOIN (SELECT * FROM t_jan_prudek_project_sql_primary_final
GROUP BY industry_branch_code, payroll_year) t2
ON t.industry_branch_code = t2.industry_branch_code
AND t.payroll_year = t2.payroll_year + 1
WHERE round ((t.salary - t2.salary) / t2.salary * 100, 2) < 0
ORDER BY payroll_year ASC
) AS tab2
JOIN (
SELECT t.name, t.payroll_year, t2.payroll_year + 1 AS year_prev,
	round((t.value-t2.value) / t2.value * 100, 2) AS food_price_growth 
FROM (SELECT * FROM t_jan_prudek_project_sql_primary_final
GROUP BY name, payroll_year) t
JOIN (SELECT * FROM t_jan_prudek_project_sql_primary_final
GROUP BY name, payroll_year) t2
	ON  t.payroll_year = t2.payroll_year + 1
	AND t.name = t2.name
	AND t.payroll_year < 2018
) AS tab1
ON tab1.payroll_year = tab2.payroll_year
WHERE ;

#testovací tabulka porovnání růtu mezd a cen 2
CREATE VIEW v_jan_prudek_price_and_wage_growth AS;
WITH food_prices AS (
  SELECT name, payroll_year, AVG(value) AS avg_price
  FROM t_jan_prudek_project_sql_primary_final
  GROUP BY name, payroll_year
),
  wage_growth AS (
  SELECT payroll_year, AVG(salary) AS avg_salary
  FROM t_jan_prudek_project_sql_primary_final
  GROUP BY payroll_year
)
SELECT fp.name, fp.payroll_year, ROUND((fp.avg_price - fp_prev.avg_price) / fp_prev.avg_price * 100, 2) AS price_growth,
       w.avg_salary AS wage_growth
FROM food_prices fp
JOIN food_prices fp_prev ON fp.name = fp_prev.name AND fp.payroll_year = fp_prev.payroll_year + 1
JOIN wage_growth w ON fp.payroll_year = w.payroll_year
WHERE (fp.avg_price - fp_prev.avg_price) / fp_prev.avg_price * 100 > 10 AND
      fp.avg_price > 0 AND
      w.avg_salary > 0
ORDER BY fp.name, fp.payroll_year;

SELECT *
FROM v_jan_prudek_price_and_wage_growth
HAVING 

#porovnání růtu mezd a cen
WITH food_prices AS (
	SELECT payroll_year, avg(value) AS average_food_prices
	FROM t_jan_prudek_project_sql_primary_final
	GROUP BY payroll_year
),
	salaries AS (
	SELECT payroll_year, avg(average_salary) AS average_total_salary
	FROM t_jan_prudek_project_sql_primary_final
	GROUP BY payroll_year
)
SELECT *
FROM (
	SELECT *, round((fp.average_food_prices - fp2.average_food_prices) / fp2.average_food_prices * 100, 2) AS average_food_prices_growth
	FROM food_prices fp
	JOIN food_prices fp2
	ON fp.payroll_year = fp2.payroll_year + 1
	) AS fprices
JOIN (
	SELECT *, round((s.average_total_salary - s2.average_total_salary) / s2.average_total_salary * 100, 2) AS average_total_salaries_growth
	FROM salaries s
	JOIN salaries s2
	ON s.payroll_year = s2.payroll_year + 1
	) AS slrs;

#pokus s union
CREATE VIEW v_jan_prudek_prices_growth AS
WITH food_prices AS (
  SELECT payroll_year, AVG(value) AS avg_price
  FROM t_jan_prudek_project_sql_primary_final
  GROUP BY payroll_year)
SELECT fp.payroll_year, ROUND((fp.avg_price - fp_prev.avg_price) / fp_prev.avg_price * 100, 2) AS price_growth
FROM food_prices fp
JOIN food_prices fp_prev ON fp.payroll_year = fp_prev.payroll_year + 1;

CREATE VIEW v_jan_prudek_salarie_growth AS
WITH salaries AS (
	SELECT payroll_year, avg(average_salary) AS average_total_salary
	FROM t_jan_prudek_project_sql_primary_final
	GROUP BY payroll_year)
SELECT s.payroll_year, ROUND((s.average_total_salary - s_prev.average_total_salary) / s_prev.average_total_salary * 100, 2) AS salary_growth
FROM salaries s
JOIN salaries s_prev ON s.payroll_year = s_prev.payroll_year + 1;

SELECT pg.payroll_year, pg.price_growth, sg.salary_growth
FROM v_jan_prudek_prices_growth pg
JOIN v_jan_prudek_salarie_growth sg
ON pg.payroll_year = sg.payroll_year
HAVING pg.price_growth - sg.salary_growth > 10;

SELECT t1.`year`, ROUND((t1.gdp - t2.gdp) / t2.gdp * 100, 2) AS gdp_growth
FROM t_jan_prudek_project_sql_secondary_final t1
JOIN t_jan_prudek_project_sql_secondary_final t2 ON t1.`year` = t2.`year` + 1
WHERE t1.country = 'Czech Republic' AND t2.country = 'Czech Republic'
ORDER BY t1.`year` ASC;

SELECT psg.payroll_year AS year, psg.price_growth, psg.salary_growth, hdp_growth.gdp_growth
FROM (
  SELECT pg.payroll_year, pg.price_growth, sg.salary_growth
  FROM v_jan_prudek_prices_growth pg
  JOIN v_jan_prudek_salarie_growth sg ON pg.payroll_year = sg.payroll_year
) AS psg
JOIN (
  SELECT t1.`year`, ROUND((t1.gdp - t2.gdp) / t2.gdp * 100, 2) AS gdp_growth
  FROM t_jan_prudek_project_sql_secondary_final t1
  JOIN t_jan_prudek_project_sql_secondary_final t2 ON t1.`year` = t2.`year` + 1
  WHERE t1.country = 'Czech Republic' AND t2.country = 'Czech Republic'
) AS hdp_growth ON psg.payroll_year = hdp_growth.`year`;

