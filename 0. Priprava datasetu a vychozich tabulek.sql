/*reálné jméno: Honza
na Discordu: EricSapphire*/

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