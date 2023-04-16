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

SELECT cp.*, cpib.name
FROM czechia_payroll cp
JOIN czechia_payroll_industry_branch cpib
ON cp.industry_branch_code = cpib.code;

SELECT cp.*, cpib.name
FROM czechia_payroll cp
JOIN czechia_payroll_industry_branch cpib
ON cp.industry_branch_code = cpib.code
WHERE value_type_code = 5958;

SELECT cp.*, cpib.name,
	AVG(value) AS year_average
FROM czechia_payroll cp
JOIN czechia_payroll_industry_branch cpib
ON cp.industry_branch_code = cpib.code
WHERE value_type_code = 5958
GROUP BY cp.payroll_year, cpib.name
ORDER BY cp.industry_branch_code, cp.payroll_year;
