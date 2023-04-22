# Engeto-Data-Academy-Project
Zadání:
    1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
    2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
    3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
    4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
    5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
    6. Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.

**1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**
Otázka míří vývoj mezd v odvětvích za neurčené časové období. Nejdříve je dobré seznámit se obsahem datových sad, se kterými máme pracovat.
Co se týče číselníků , pmocí jednoduchých dotazů zjistíme:
  - zkoumáme celkem 19 odvětví
  - fyzický nebo přepočtený
  - číselné hodnoty mohou nabývat jednotek v tisících obyvatel nebo v Kč
  - hodnoty mohou znamenat průměrný počet zaměstnaných osob nebo průměrnou mzdu na zaměstnance;

Když prozkoumáme naši hlavní tabulku czechia_payroll, zjistíme, že obsahuje celkem 6 880 záznamů, kde hlavním klíčem je ID. Na první pohled vidíme, že spusta
hodnot ve sloupci "value" je nulitních. Týká se to oboru zemědělství, lesnictví, rybářství, kde se nezaznamenávají na čtvrtletní bázi, ale jen na roční.
Díky číselníku ve sloupci value_type_code ale víme, že se jedná o počet zaměstnanců, což pro nás pro určení růstu nebo poklesu mzdy za období není relevantní informace,
proto si potřebujeme vyfiltrovat záznamy jen na mzdu.
Číselník pro průměrnou hrubou mzdu na zaměstnance je 5958, proto lze data pomocí tohoto klíče vyfiltrovat. Co zde může být chybou, ve sloupci unit_code je u
takto vyfiltrovaných záznamů číslo 200, což dle číselníku má být tisíc obyvatel, naopak Kč má mít číslo 80403.

V nově vytvořeném náhledu tak vidíme pouze mzdy, nikoliv počet zaměstnanců. Z tabulky je zřejmé, že data jsou rozdělena na kvartály v jednotlivých letech.
Zadaný dotaz Je proto potřeba

Z vytvořená tabulky pak můžeme číst data po zprůměrování hodnot za kvartál daného roku. Vidíme, že pokles přišel v roce 2012 u odvětví těžba a dobývání, kdy mzda po roce 2012 poklesla pod hranici 32 000 Kč, kam se vrátila až v roce 2017. Průměrná mzda klesla po roce 2012 i u odvětví Výroba a rozvoz elektřiny, plynu, tepla a klimatiz. vzduchu, kdy mzda klesla pod 42 000 Kč a navrátila se nad tuto hodnotu až v roce 2017. U ubytování, stravování a pohostinství došlo k významnějšímu poklesu mezd v roce 2020. Významný pokles v roce 2013 vidíme u odvětví peněžnictví a pojišťovnictví, kdy průměr za rok 2012, který řinil přes 50 000 Kč, klesl v roce 2013 na 45 000 Kč.

Abychom tak odpověděli na otázku, **v širším časovém horizontu mzdy rostou ve všech odvětvích, ale existují odvětví, které zaznamenává výchylky z tendence růst, zvláště v roce 2012 nebo v roce 2020.**

**2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?**
  
 Díky tabulce czechia_price_category víme, že máslo má v tabulce czechia_price číslo 115101 a chleba 111301.
 
 
  
**6. Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.**

Použitý kód vytvoří tabulku, která vznikne spojením tabulky economies a countries, o pěti sloupcích - country, gdp, gini, year, continent. Společným kličem obou spojovaných tabulek je sloupec country v každé z nich. Pomocí klauzule WHERE si vyfiltrujeme pouze země, které se nacházejí v Evropě. Vzhledem k tomu, že nás zajímá jen období stejné jako primární přehled pro ČR, který zaobírá období 2000 - 2021. Aby byla tabulka pěkně přehledná, seřadíme si data podle zemí a roku.
