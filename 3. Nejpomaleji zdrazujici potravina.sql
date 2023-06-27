#nejpomaleji zdražující potravina
SELECT t.name,
	avg(round((t.value-t2.value) / t2.value * 100, 2)) AS food_price_growth 
FROM (SELECT * FROM t_jan_prudek_project_sql_primary_final
GROUP BY name, payroll_year) t
JOIN (SELECT * FROM t_jan_prudek_project_sql_primary_final
GROUP BY name, payroll_year) t2
	ON  t.payroll_year = t2.payroll_year + 1
	AND t.name = t2.name
	AND t.payroll_year < 2018
GROUP BY name
ORDER BY food_price_growth;