#vytvoření náhledů VIEW
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

#pomocná tabulka ke zjištění meziroční změny HDP v České republice
SELECT t1.`year`, ROUND((t1.gdp - t2.gdp) / t2.gdp * 100, 2) AS gdp_growth
FROM t_jan_prudek_project_sql_secondary_final t1
JOIN t_jan_prudek_project_sql_secondary_final t2 ON t1.`year` = t2.`year` + 1
WHERE t1.country = 'Czech Republic' AND t2.country = 'Czech Republic'
ORDER BY t1.`year` ASC;

#finální dotaz na vliv změny HDP na ceny a mzdy v České republice
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