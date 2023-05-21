# Engeto-Data-Academy-Project
Zadání:
    1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
    2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
    3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
    4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
    5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
    6. Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.
**0. Příprava datových podkladů pro další dotazování**
A) czechia_payroll
Nejdříve je dobré seznámit se obsahem datových sad, se kterými máme pracovat.
Co se týče číselníků pro czechia_payroll, pomocí jednoduchých dotazů zjistíme:
- z číselníku czechia_payroll_industry_branch (https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/301eed27a42bbb71925206d208d5e255745d4c3d/JP_SQL_projekt_final.sql#L2-L3) zjistíme, že zkoumáme celkem 19 odvětví, vzhledem k tomu, že v hlavní tabulce czechia_payroll jsou odvětví označena jen písmeny, je pro nás tento číselník důležitý pro lepší orientaci ve výsledcích;
- z číselníku czechia_payroll_calculation (https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/301eed27a42bbb71925206d208d5e255745d4c3d/JP_SQL_projekt_final.sql#L5C9-L6) zjistíme, že kalkulaci mzdy můžeme nabývat hodnot fyzický nebo přepočtený, pro náš případ se tak nebude jednat o důležitou tabulku
- z číselníku czechia_payroll_unit (https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/301eed27a42bbb71925206d208d5e255745d4c3d/JP_SQL_projekt_final.sql#L8-L9) zjistíme, že číselné hodnoty mohou nabývat jednotek v tisících obyvatel nebo v Kč, tato informace je pro nás důležitá tehdy, když budeme potřebovat rozlišit mezi počtem osob a peněžními kalkulacemi;
- číselník czechia_payroll_value_type (https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/301eed27a42bbb71925206d208d5e255745d4c3d/JP_SQL_projekt_final.sql#L11-L12) má podobnou funkci jako předchozí číselník, kdy hodnoty mohou znamenat průměrný počet zaměstnaných osob nebo průměrnou mzdu na zaměstnance, pro nás bude zásadní hodnota vždy ta, které odpovídá zadání otázky, pokud se například budeme ptát na vývoj mezd, tak vezmeme v potaz průměrnou mzdu;

Když prozkoumáme naši hlavní tabulku czechia_payroll, zjistíme, že obsahuje celkem 6 880 záznamů, kde hlavním klíčem je ID. Na první pohled vidíme, že spusta
hodnot ve sloupci "value" je nulitních. Týká se to oboru zemědělství, lesnictví, rybářství, kde se nezaznamenávají na čtvrtletní bázi, ale jen na roční. Navíc první záznam vidíme až v roce 2003, předchozí roky zcela chybí.

Díky číselníku ve sloupci value_type_code ale víme, že se jedná o počet zaměstnanců, což pro nás pro určení růstu nebo poklesu mzdy za období není relevantní informace, proto si potřebujeme vyfiltrovat záznamy jen na mzdu. Číselník pro průměrnou hrubou mzdu na zaměstnance je 5958, proto lze data pomocí tohoto klíče vyfiltrovat.

Nakonec si tak můžeme vytvořit pomocnou tabulku (https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/301eed27a42bbb71925206d208d5e255745d4c3d/JP_SQL_projekt_final.sql#L18-L25), která bude vycházet z tabulky czechia_payroll a ukáže nám pouze údaje o mzdách, doplníme ji o sloupec průměrných mezd podle průmyslového odvětví a roku. Spojíme ji zároveň s tabulkou czechia_payroll_industry_branch, ať pro nás nejsou data zcela anonymní a můžeme k nim jednoduše přiřadit název jednotlivých průmyslových odvětví.

B) czechia_price
Stejně můžeme postupovat i naší další relevantní tabulky czechia_price, která nám ukazuje vývoj cen.

Pří prozkoumání tabulky czechia_price (https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/8ab7ad808da62f54b4d7b7885e3a353897505797/JP_SQL_projekt_final.sql#L29-L30) zjistíme, že obsahuje následující sloupce: ID (jako hlavní klíč), value, category_code, date_from, date_to, region_code.
Při prozkoumání číselníků zjistíme, že:
- z číselníku czechia_price_category (https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/8ab7ad808da62f54b4d7b7885e3a353897505797/JP_SQL_projekt_final.sql#L32-L33) zjistíme, co se skrývá pod kódy v primární tabulce czechia_price ve sloupci category_code: Každý kód má přiřazen nějakou potravinu v určitém zkoumaném jednotkovém množství, např. kód 111101 značí 1kg loupané rýže, kód 114401 značí 150g netučného bílého jogurtu apod.)
- z číselníku czechia_region (https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/8ab7ad808da62f54b4d7b7885e3a353897505797/JP_SQL_projekt_final.sql#L35-L36) zjistíme kódy jednotlivých krajů podle NUTS regionů. Tyto údaje se nachází v primární tabulce czechia_price ve sloupci region_code. Vzhledem k tomu, že žádná z následujících otázek nemíří na konkrétní region, jsou využívány údaje celorepublikové a i proto tento číselník v pro nás bude mít spíše marginální význam.

Nakonec i pro mzdy si můžeme vytvořit pomocnou tabulku, která bude obsahovat jen pro naše zkoumání relevantní údaje (https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/8ab7ad808da62f54b4d7b7885e3a353897505797/JP_SQL_projekt_final.sql#L39-L43). Vytvoříme tak tabulku, která obsahuje všechny sloupce z tabulky czechia_price a czechia_price_category. Tyto tabulky vzájemně spojíme na hodnotách sloupce obsahující kódy kategorií potravin. Pomocí klauzule WHERE si vyfiltrujeme dotazy, které ve sloupci region_code obsahují jen nulitní hodnoty, protože se nechceme zaměřovat na konkrétní region.

C) vytvoření primární tabulky t_jan_prudek_project_sql_primary_final
Nyní můžeme přistoupit k vytvoření primární tabulky, která bude obsahovat všechna data k zodpovězení všech následujících otázek. Již v předchozích dotazech jsme vytvořili náhled z tabulky czechia_payroll a czechia_price tak, že obsahovala všechna relevantní data, respektive nerelevantní data byla vynechána. Tyto dva dotazy tak nyní musíme spojit v jeden, který vytvoří kýženou tabulku t_jan_prudek_project_sql_primary_final (https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/8ab7ad808da62f54b4d7b7885e3a353897505797/JP_SQL_projekt_final.sql#L46-L64)

Vzali jsme tedy pomocnou tabulku vytvořenou z czechia_payroll a pomcocnou tabulku vytvořenou z czechia_price, pomocí vnořených SELECT jsme je spojili na sloupci "year" a pomocí klauzule CREATE TABLE jsme vytvořili tabulku t_jan_prudek_project_sql_primary_final.

**1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**
Nyní se tak můžeme vrhnout na zodpovězení jednotlivých otázek. Otázka č.1 míří vývoj mezd v odvětvích za neurčené časové období.

Musíme sledovat meziroční změny u jednotlivých průmyslových odvětví. Vzhledem k tomu, že tabulka nám meziroční změnu neukazuje, musíme si náhled meziročních změn vytvořit sami pomocí spojení tabulky samu se sebou. Pomocí klauzule JOIN tak spojíme primární tabulku samu se sebou na sloupcích industry_branch_code a year, kdy ale year první tabulky se rovná year + 1 druhé tabulky (https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/8ab7ad808da62f54b4d7b7885e3a353897505797/JP_SQL_projekt_final.sql#L86-L89).

Nyní musíme vypočítat i meziroční změnu (https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/8ab7ad808da62f54b4d7b7885e3a353897505797/JP_SQL_projekt_final.sql#L83). Vzhledem k tomu, že nás zajímá jen meziroční pokles mezd, vyfiltrujeme se výsledky na ty, kde v nově vytvořeném sloupci salary_growth najdeme hodnoty menší než 0 (https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/8ab7ad808da62f54b4d7b7885e3a353897505797/JP_SQL_projekt_final.sql#L90)

Pokud provedeme celý kód (https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/8ab7ad808da62f54b4d7b7885e3a353897505797/JP_SQL_projekt_final.sql#L82-L91), zjistíme, že opravdu existují odvětví, ve kterých mzdy i klesají. Dokonce každé odvětví zažilo alespoň jeden pokles, zejména mezi lety 2009 - 2013, kde se ČR zmítala v ekonomické recesi.

**2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?**
 
V tomto úkolu je problém v tom, že se dotazuje na první a poslední srovnatelné období. Konkrétní roky nás v tuto chvíli nezajímají, ty zjistíme pomocí klauzulí MAX a MIN. Pro zjištění si předpřipravíme dvě tabulky, jednu pro zjištění množství potravin v prvním a druhou pro zjištění množství potravin v posledním sledovaném roce. Tabulky budou mít více méně stejnou strukturu. vybereme si rok a jméno potraviny a vyvoříme si sloupec s výpočtem množství dané potravinyy, kterou si můžeme koupit za mnzdu v daném sledovaném období. Pomocí klauzule WEHRE výsledky omezíme jen na první (v první tabulce) a poslední (v druhé tabulce) sledované období a na data obsahující ve sloupci name "mléko" a "chléb". Obě tyto tabulky poté spojíme pomocí klauzule UNION (https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/ef83a972b676418afd9fe235d1a0bfdc004b7143/JP_SQL_projekt_final.sql#L94-L105), čímž získáme následující výsledek:
2006	Chléb konzumní kmínový	1294.0
2006	Mléko polotučné pasterované	1437.0
2018	Mléko polotučné pasterované	1642.0
2018	Chléb konzumní kmínový	1342.0

**3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?*

I tato otázka míří na porovnání růstu cen, je tedy opět potřeba porovnat primární tabulku samu se sebou, abychom mohli vypočítat meziroční zvýšení. Pomocí vnořeného SELECT propojíme primární tabulku samu se sebou, seskupenou podle jména a sledovaného roku. Z hodnot vypočítáme průměr a seskupíme podle jména. Nakonec výsledek seřadíme, přičemž tabulka je automaticky seřazena vzestupně, což znamená, že první potraviny ve výsledné tabulce mají nejmenší průměrný meziroční nárůst a zdražují tak nejpomaleji.
https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/c1ec429e2efbf74b78c1e2b647fdcf4334d00d24/JP_SQL_projekt_final.sql#L117-L127

Jedná se o:
Banány žluté	0.194545
Jakostní víno bílé	0.23
Cukr krystalový	0.458182
...

**4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?**
 
 **5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?**

Zde je zásadní mít již vytvořenou tabulku s makroekonomickými údaji států, které jejíž vytvoření je podrobněji popsáno níže v úkolu č. 6.
  
**6. Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.**

Ač je tento úkol zadán jako dodatečný, je potřeba jej splnit již před zodpovězením na ozázku č. 5, proto je vytvořen již na začátku celého kódu:
https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/301eed27a42bbb71925206d208d5e255745d4c3d/JP_SQL_projekt_final.sql#LL55C1-L65C3

Použitý kód vytvoří tabulku, která vznikne spojením tabulky economies a countries, o pěti sloupcích - country, gdp, gini, year, continent. Společným kličem obou spojovaných tabulek je sloupec country v každé z nich. Pomocí klauzule WHERE si vyfiltrujeme pouze země, které se nacházejí v Evropě. Vzhledem k tomu, že nás zajímá jen období stejné jako primární přehled pro ČR, který zaobírá období 2000 - 2021, pomocí klauzule HAVING omezíme výsledky na ty, které ve sloupci e.'year' obsahují hodnotu vyšší než "1999". Aby byla tabulka pěkně přehledná, seřadíme si data podle zemí a roku.
