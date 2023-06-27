#množství mléka a chleba za mzdu v daném roce
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