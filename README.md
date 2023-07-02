# Engeto-Data-Academy-Project
reálné jméno: Honza  
na Discordu: EricSapphire

Zadání:  
    1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?  
    2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?  
    3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?  
    4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?  
    5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?  
    6. Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.  
    
**0. Příprava datových podkladů pro další dotazování**  
*A) czechia_payroll*  
Nejdříve je dobré seznámit se obsahem datových sad, se kterými máme pracovat.  
Co se týče číselníků pro czechia_payroll, pomocí jednoduchých dotazů zjistíme:  
- z číselníku czechia_payroll_industry_branch https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/0.%20Priprava%20datasetu%20a%20vychozich%20tabulek.sql#L5-L6 zjistíme, že zkoumáme celkem 19 odvětví. Vzhledem k tomu, že v hlavní tabulce czechia_payroll jsou odvětví označena jen písmeny, je pro nás tento číselník důležitý pro lepší orientaci ve výsledcích;  
- z číselníku czechia_payroll_calculation https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/0.%20Priprava%20datasetu%20a%20vychozich%20tabulek.sql#L8-L9 zjistíme, že kalkulace mzdy může nabývat hodnot fyzický nebo přepočtený, pro náš případ se tak nebude jednat o důležitou tabulku;  
- z číselníku czechia_payroll_unit https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/0.%20Priprava%20datasetu%20a%20vychozich%20tabulek.sql#L11-L12 zjistíme, že číselné hodnoty mohou nabývat jednotek v tisících obyvatel nebo v Kč, tato informace je pro nás důležitá tehdy, když budeme potřebovat rozlišit mezi počtem osob a peněžními kalkulacemi;  
- číselník czechia_payroll_value_type https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/0.%20Priprava%20datasetu%20a%20vychozich%20tabulek.sql#L14-L15 má podobnou funkci jako předchozí číselník, kdy hodnoty mohou znamenat průměrný počet zaměstnaných osob nebo průměrnou mzdu na zaměstnance. Pro nás bude zásadní hodnota vždy ta, které odpovídá zadání otázky, pokud se například budeme ptát na vývoj mezd, tak vezmeme v potaz průměrnou mzdu;

Když prozkoumáme naši hlavní tabulku czechia_payroll, zjistíme, že obsahuje celkem 6 880 záznamů, kde hlavním klíčem je ID. Na první pohled vidíme, že spousta
hodnot ve sloupci "value" je nulitních. Týká se to oboru zemědělství, lesnictví, rybářství, kde se nezaznamenávají na čtvrtletní bázi, ale jen na roční. Navíc první záznam vidíme až v roce 2003, předchozí roky zcela chybí.

Díky číselníku ve sloupci value_type_code ale víme, že se jedná o počet zaměstnanců, což pro nás není relevantní informace, protože ze zadání víme, že všechny otázky týkající se tabulky czechia_payroll se týkají mezd, nikoliv počtu zaměstnanců. Proto si potřebujeme vyfiltrovat záznamy jen na mzdu. Číselník pro průměrnou hrubou mzdu na zaměstnance je 5958, proto lze data pomocí tohoto klíče vyfiltrovat.

Nakonec si tak můžeme vytvořit pomocnou tabulku https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/0.%20Priprava%20datasetu%20a%20vychozich%20tabulek.sql#L21-L28, která bude vycházet z tabulky czechia_payroll a ukáže nám pouze údaje o mzdách, doplníme ji o sloupec průměrných mezd podle průmyslového odvětví a roku. Spojíme ji zároveň s tabulkou czechia_payroll_industry_branch, ať pro nás nejsou data zcela anonymní a můžeme k nim jednoduše přiřadit název jednotlivých průmyslových odvětví.

*B) czechia_price*
Stejně můžeme postupovat i s naší další relevantní tabulkou czechia_price, která nám ukazuje vývoj cen.

Pří prozkoumání tabulky czechia_price https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/0.%20Priprava%20datasetu%20a%20vychozich%20tabulek.sql#L32-L33 zjistíme, že obsahuje následující sloupce: ID (jako hlavní klíč), value, category_code, date_from, date_to, region_code.
Při prozkoumání číselníků zjistíme, že:  
- z číselníku czechia_price_category https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/0.%20Priprava%20datasetu%20a%20vychozich%20tabulek.sql#L35-L36 vyplývá, co se skrývá pod kódy v primární tabulce czechia_price ve sloupci category_code: Každý kód má přiřazen nějakou potravinu v určitém zkoumaném jednotkovém množství, např. kód 111101 značí 1kg loupané rýže, kód 114401 značí 150g netučného bílého jogurtu apod.;  
- z číselníku czechia_region https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/0.%20Priprava%20datasetu%20a%20vychozich%20tabulek.sql#L38-L39 zjistíme kódy jednotlivých krajů podle NUTS. Tyto údaje se nachází v primární tabulce czechia_price ve sloupci region_code. Vzhledem k tomu, že žádná z kladenývh otázek nemíří na konkrétní region, jsou využívány údaje celorepublikové a i proto tento číselník v pro nás bude mít spíše marginální význam.

Nakonec i pro mzdy si můžeme vytvořit pomocnou tabulku, která bude obsahovat jen pro naše zkoumání relevantní údaje https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/0.%20Priprava%20datasetu%20a%20vychozich%20tabulek.sql#L42-L46. Vytvoříme tak tabulku, která obsahuje všechny sloupce z tabulky czechia_price a czechia_price_category. Tyto tabulky vzájemně spojíme na hodnotách sloupce obsahující kódy kategorií potravin. Pomocí klauzule WHERE si vyfiltrujeme dotazy, které ve sloupci region_code obsahují jen nulitní hodnoty, protože se nechceme zaměřovat na konkrétní region.

*C) vytvoření primární tabulky t_jan_prudek_project_sql_primary_final*  
Nyní můžeme přistoupit k vytvoření primární tabulky, která bude obsahovat všechna data k zodpovězení všech následujících otázek. Již v předchozích dotazech jsme vytvořili náhledy z tabulky czechia_payroll a czechia_price tak, že obsahovaly všechna relevantní data, respektive nerelevantní data byla vynechána. Tyto dva dotazy tak nyní musíme spojit v jeden, který vytvoří kýženou tabulku t_jan_prudek_project_sql_primary_final https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/0.%20Priprava%20datasetu%20a%20vychozich%20tabulek.sql#L49-L67

Vzali jsme tedy pomocnou tabulku vytvořenou z czechia_payroll a pomcocnou tabulku vytvořenou z czechia_price, pomocí vnořených SELECT jsme je spojili na sloupci "year" a pomocí klauzule CREATE TABLE jsme vytvořili tabulku t_jan_prudek_project_sql_primary_final.

**1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**  
Nyní se tak můžeme vrhnout na zodpovězení jednotlivých otázek. Otázka č.1 míří vývoj mezd v odvětvích za neurčené časové období.

Musíme sledovat meziroční změny u jednotlivých průmyslových odvětví. Vzhledem k tomu, že tabulka nám meziroční změnu neukazuje, musíme si náhled meziročních změn vytvořit sami pomocí spojení tabulky samé se sebou. Pomocí klauzule JOIN tak spojíme primární tabulku samu se sebou na sloupcích industry_branch_code a year, kdy ale year první tabulky se rovná year + 1 druhé tabulky https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/1.%20Odvetvi%20ve%20kterem%20mzdy%20klesaly.sql#L6-L9.

Nyní musíme vypočítat i meziroční změnu https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/1.%20Odvetvi%20ve%20kterem%20mzdy%20klesaly.sql#L3. Vzhledem k tomu, že nás zajímá jen meziroční pokles mezd, vyfiltrujeme se výsledky na ty, kde v nově vytvořeném sloupci salary_growth najdeme hodnoty menší než 0 https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/1.%20Odvetvi%20ve%20kterem%20mzdy%20klesaly.sql#L10

Pokud provedeme celý kód https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/1.%20Odvetvi%20ve%20kterem%20mzdy%20klesaly.sql#L2-L11, zjistíme, že opravdu existují odvětví, ve kterých mzdy i klesají. Dokonce každé odvětví zažilo alespoň jeden pokles, zejména mezi lety 2009 - 2013, kde se ČR zmítala v ekonomické recesi.

**2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?**
 
V tomto úkolu je problém v tom, že se dotazuje na první a poslední srovnatelné období. Konkrétní roky nás v tuto chvíli nezajímají, ty zjistíme pomocí klauzulí MAX a MIN. Pro zjištění si předpřipravíme dvě tabulky, jednu pro zjištění množství potravin v prvním a druhou pro zjištění množství potravin v posledním sledovaném roce. Tabulky budou mít více méně stejnou strukturu. vybereme si rok a jméno potraviny a vyvoříme si sloupec s výpočtem množství dané potravinyy, kterou si můžeme koupit za mnzdu v daném sledovaném období. Pomocí klauzule WEHRE výsledky omezíme jen na první (v první tabulce) a poslední (v druhé tabulce) sledované období a na data obsahující ve sloupci name "mléko" a "chléb". Obě tyto tabulky poté spojíme pomocí klauzule UNION 
https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/2.%20Mnozstvi%20chleba%20a%20mleka%20za%20mzdu%20v%20danem%20roce.sql#L2-L13
, čímž získáme následující výsledek:

 | rok | potravina | množství |
 | :---- | :---- | :--- |
 | 2006 | Chléb konzumní kmínový | 1294.0 |
 | 2006 | Mléko polotučné pasterované | 1437.0 |
 | 2018 | Mléko polotučné pasterované | 1642.0 |
 | 2018 | Chléb konzumní kmínový | 1342.0 |

**3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?**

I tato otázka míří na porovnání růstu cen, je tedy opět potřeba porovnat primární tabulku samu se sebou, abychom mohli vypočítat meziroční zvýšení. Pomocí vnořeného SELECT propojíme primární tabulku samu se sebou, seskupenou podle jména a sledovaného roku. Z hodnot vypočítáme průměr a seskupíme podle jména. Nakonec výsledek seřadíme, přičemž tabulka je automaticky seřazena vzestupně, což znamená, že první potraviny ve výsledné tabulce mají nejmenší průměrný meziroční nárůst a zdražují tak nejpomaleji.
https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/3.%20Nejpomaleji%20zdrazujici%20potravina.sql#L2-L12

Jedná se o:

 | potravina | průměrná změna ceny |
 | :----| :---- |
 | Banány žluté | 0.194545 |
 | Jakostní víno bílé | 0.23 |
 | Cukr krystalový | 0.458182 |
 | ... | ... |

**4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?**
 
*A) Vytvoření náhledů*
V prvé řadě je nejjednoduší vytvoření si dvou náhledů, které zajistí informaci ohledně růstu mezd a cen, aby nenastal případný konflikt ve jménech sloupců, pokud by byl vytvořen jeden komplexní dotaz. Oba náhledy mají stejnou strukturu. S užitím Common Table Expression si "předvytvoříme" dočasnou tabulku s průměrnou mzdou a cenou seskupenou podle roku. Pomocí těchto náhledů poté s pomocí vzájemného spojení přes sloupec year vypočítáme meziroční nárůst mez a cen.

Výsledný dotaz vypadá následovně pro  
i. ceny potravin
https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/4.%20Vyrazny%20rust%20cen%20oproti%20rustu%20mezd.sql#L2-L9

ii. pro mzdy
https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/4.%20Vyrazny%20rust%20cen%20oproti%20rustu%20mezd.sql#L11-L18

*B) Výsledný dotaz*  
Vzhledem k tomu, že již máme údaje o meziročním růstu cen a meziročním růstu mezd separátně, musíme jen zjistit, zda existuje rok, kdy je růst cen vyšší než růst mezd. Toho docílíme prostým odečtením růstu mezd za daný rok od růstu cen. Pokud je výsledek větší než 10 %, což je podle zadání výrazně vyšší růst, dostaneme odpověď na zadanou otázku.
https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/4.%20Vyrazny%20rust%20cen%20oproti%20rustu%20mezd.sql#L21-L25
Pokud provedeme daný dotaz, nedostaneme žádný výsledek, tudíž v žádném roce sledovaném nerostly ceny výrazně víc než mzdy.
 
 **5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?**

Zde je zásadní mít již vytvořenou tabulku s makroekonomickými údaji států, jejíž vytvoření je podrobněji popsáno níže v úkolu č. 6. Zde je úkol náročný v tom, že musíme propojit několik tabulek za účelem zjištění meziročního nárůstu dané zkoumané hodnoty (ostatně jako v úkolu č. 4). Nejjednodušší v tomto případě bylo nejít cestou jednoho komplexního dotazu, ale rozdělit si dotazy na vícero a následně je spojit v jeden výsledný dotaz.

K tomu využijeme již vytvořených náhledů z úkolu č. 5, protože ty nám dávají průměrný růst mezd a cen za daný rok. Je nutné zjištit meziroční nárůst HDP v ČR a výsledky následně porovnat. Tohoto dosáhneme opět pomocí propojení sekundární tabulky samé se sebou. V rámci SELECT klauzule vypočítáme i meziroční růst HDP. Výsledky si vyfiltrujeme pouze na Českou republiku u obou propojených tabulek.  
Výsledný dotaz vypadá následovně:

https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/5.%20Vliv%20HDP%20na%20zmenu%20cen%20a%20mezd%20v%20CR.sql#L21-L25

Vzhledem k tomu, že údaje o meziroční změně mezd a cen jsme vymezili do samostatného náhledu a meziroční růst HDP jsme si předepsali, výsledný dotaz bude jednodušší. Nyní jen musíme všechny předešlé dotazy spojit do jednoho dotazu, abychom získali výsledek. Pomocí vnořeného SELECT spojíme oba vytvořené náhledy do jedné tabulky na roku a tuto výslednou tabulku následně propojíme s tabulkou růstu HDP v ČR, kterou jsme se předpřipravili výše. Tabulky spojíme opět na rocích.  

https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/5.%20Vliv%20HDP%20na%20zmenu%20cen%20a%20mezd%20v%20CR.sql#L28-L39
  
Po provedení dotazu získáme následující tabulku:  

 | rok | ceny | mzdy | HDP |
 | :--- | :---- |:---- |:--- |
 | 2007 | 6.35 | 6.84 | 5.57 |
 | 2008 | 6.41 | 7.87 | 2.69 |
 | 2009	| -6.81 | 3.16 | -4.66 |
 | 2010	| 1.77 | 1.95 | 2.43 |
 | 2011	| 3.5 | 2.30 | 1.76 |
 | 2012	| 6.92 | 3.03 | -0.79 |
 | 2013	| 5.55 | -1.56 | -0.05 |
 | 2014	| 0.89 | 2.56 | 2.26 |
 | 2015	| -0.56 | 2.51 | 5.39 |
 | 2016	| -1.12 | 3.65 | 2.54 |
 | 2017	| 9.98 | 6.28 | 5.17 |
 | 2018	| 1.95 | 7.62 | 3.2 |

Můžeme tak vysledovat jistou korelaci mezi výší HDP a cenami potravin či mezd. V roce 2007 dosáhlo HDP přes pět procent a mzdy ve stejném a následujícím roce rostly o nominálně procento až dvě více než HDP. V krizových letech 2008 - 2014, s důrazem na vrchol finanční krize 2009, byl růst HDP pomalejší, respektive v roce 2009 byl dokonce výrazně v mínusu. Mzdy odpovídaly chabému ekonomickému výkonu a rostly jen neznatelně.  

**6. Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.**

Ač je tento úkol zadán jako dodatečný, je potřeba jej splnit již před zodpovězením na ozázku č. 5, proto je vytvořen již v souboru s pořadovým číslem 0., který se zabývá prozkoumáním jednotlivých datasetů a přípravě primární a sekundární tabulky:

https://github.com/EricSapphire/Engeto-Data-Academy-Project/blob/0ebe2d5e12affe93d844f0c0ef767dc46382cae4/0.%20Priprava%20datasetu%20a%20vychozich%20tabulek.sql#L70C1-L79C3

Použitý kód vytvoří tabulku, která vznikne spojením tabulky economies a countries, o pěti sloupcích - country, gdp, gini, year, continent. Společným kličem obou spojovaných tabulek je sloupec country v každé z nich. Pomocí klauzule WHERE si vyfiltrujeme pouze země, které se nacházejí v Evropě. Vzhledem k tomu, že nás zajímá jen období stejné jako primární přehled pro ČR, který zaobírá období 2000 - 2021, pomocí klauzule HAVING omezíme výsledky na ty, které ve sloupci e.'year' obsahují hodnotu vyšší než "1999". Aby byla tabulka pěkně přehledná, seřadíme si data podle zemí a roku.
