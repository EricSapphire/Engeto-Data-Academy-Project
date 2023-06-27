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