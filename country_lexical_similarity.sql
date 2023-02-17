/*---------------------------------------------------
 Create Table for all language pairs
  * ` Not every language exists in the LangName_1 column
  * ` Join tables with union so every combination of 
		pairs exist in both LangName_1 and LangName_2
  * ` This allows filtering in Tableau
----------------------------------------------------*/
CREATE TABLE all_language_pairs
	(LangName_1 NVARCHAR(250),	-- First language
	 LangName_2 NVARCHAR(250),  -- Second language for comparison
	 Similarity FLOAT,			-- Similarity between both languages
	 Robustness NVARCHAR(250)); -- Size of word groups used for similarity comparison

-- Append LangName_2 to LangName_1 with UNION
INSERT INTO all_language_pairs
	SELECT LangName_1, LangName_2, Similarity, Robustness
	FROM Sheet1$
		UNION
	SELECT LangName_2, LangName_1, Similarity, Robustness
	FROM Sheet1$;
/*---------------------------------------------------
 Create table with left anti-join to find data incompatibilities 
  * ` Searching for differences in naming conventions
		between a Country's '1st_official' language
		and the language name in LangName_1
----------------------------------------------------*/
CREATE TABLE country_missing_lang
	(Country NVARCHAR(250),
	 First_official NVARCHAR(250));

INSERT INTO country_missing_lang
SELECT 
	w."Territory/Country", 
	w."1st_official"
FROM WorldLanguage$ AS w
LEFT JOIN all_language_pairs
	ON w."1st_official" = LangName_1
	WHERE LangName_1 IS NULL;

-- Count the NULL values grouping by 1st_official Language
SELECT First_official, COUNT(*) AS count_null
FROM country_missing_lang
GROUP BY First_official
ORDER BY count_null DESC;
/*---------------------------------------------------
  * ` Arabic (21 NULL values)
  * ` Standard Chinese or Mandarin (3 NULL values)
	 * ` Indicates different names for the official language
			in the language pair table
  * ` 26 different 1st_official languages with exactly (1 NULL value)
	* ` Could mean missing data in language pair table
----------------------------------------------------*/

-- Arabic has 21 NULL values, find how it's named in all_language_pairs
SELECT DISTINCT(LangName_1)
FROM all_language_pairs
WHERE LangName_1 LIKE '%Arab%';	

-- Duplicate WorldLanguage$ before updating
CREATE TABLE dup_wl
	(Country NVARCHAR(250),
	 First_official NVARCHAR(250));

INSERT INTO dup_wl
	SELECT "Territory/Country", "1st_official"
	FROM WorldLanguage$;
/*---------------------------------------------------
 Update "1st_official" in dup_wl
  * ` starting with Arabic
----------------------------------------------------*/

UPDATE dup_wl
SET First_official = CASE 
						WHEN Country = 'Egypt' THEN 'Egyptian Arabic'
						WHEN Country = 'Morocco' THEN 'Moroccan Arabic'
						WHEN First_official = 'Arabic' THEN 'Standard Arabic'
					END
WHERE First_official = 'Arabic';	-- 21 rows updated means all Arabic NULLs are fixed

/*---------------------------------------------------
 Update First_official in dup_wl for countries in #country_missing_lang
  * ` Starting with East Asian languages
  ^ ` Find the LangName in all_language_pairs for matching
----------------------------------------------------*/
SELECT DISTINCT(LangName_1)
FROM all_language_pairs
WHERE LangName_1 LIKE ('%Mand%')
   OR LangName_1 LIKE ('%Indo%')
   OR LangName_1 LIKE ('%Malay%')
   OR LangName_1 LIKE ('%Burm%')
   OR LangName_1 LIKE ('%Fili%')
   OR LangName_1 LIKE ('%Taga%')
   OR LangName_1 LIKE ('%Cant%')
   OR LangName_1 LIKE ('%Mong%');


SELECT Country, First_official
FROM dup_wl
WHERE First_official LIKE ('%Chin%')
   OR First_official LIKE ('%Mand%')
   OR First_official LIKE ('%Indo%')
   OR First_official LIKE ('%Malay%')
   OR First_official LIKE ('%Burm%')
   OR First_official LIKE ('%Fili%')
   OR First_official LIKE ('%Taga%')
   OR First_official LIKE ('%Cant%')
   OR First_official LIKE ('%Mong%');

UPDATE dup_wl
SET First_official = CASE 
						WHEN Country = 'China' THEN 'Mandarin Chinese'
						WHEN Country = 'Hong Kong S.A.R.' THEN 'Yue Chinese' -- Cantonese
						WHEN Country = 'Singapore' THEN 'Mandarin Chinese'
						WHEN Country = 'Taiwan' THEN 'Mandarin Chinese'
						WHEN Country = 'Philippines' THEN 'Tagalog'
						WHEN Country = 'Indonesia' THEN 'Indonesian'
						WHEN Country = 'Malaysia' THEN 'Malay'
						WHEN Country = 'Mongolia' THEN 'Mongolian'
						WHEN Country = 'Myanmar' THEN 'Burmese'
						ELSE First_official
					END;


/*---------------------------------------------------
 Update First_official in dup_wl for countries in #country_missing_lang
  * ` Continuing with European languages
  * ` Find the LangName in all_language_pairs for matching if Exists
----------------------------------------------------*/

SELECT DISTINCT(LangName_1)
FROM all_language_pairs
WHERE LangName_1 LIKE ('%Greek%')
   OR LangName_1 LIKE ('%Bos%')
   OR LangName_1 LIKE ('%Eston%')
   OR LangName_1 LIKE ('%Latv%')
   OR LangName_1 LIKE ('%Mold%')
   OR LangName_1 LIKE ('%Mont%')
   OR LangName_1 LIKE ('%Norw%')
   OR LangName_1 LIKE ('%Serb%');


-- Update Modern Greek to Greek in language pairs
UPDATE all_language_pairs
	SET LangName_1 = 'Greek'
	WHERE LangName_1 = 'Modern Greek'

-- Update Norwegian Nynorsk to Norwegian in language pairs
UPDATE all_language_pairs
	SET LangName_1 = 'Norwegian'
	WHERE LangName_1 = 'Norwegian Nynorsk'
/*---------------------------------------------------
 Missing data for Bosnian, Estonian, Latvian, Moldovan, Montenegrin, Serbian
 * ` Now 21 NULL values in LangName_1 which our data doesn't have, Proceed 
 * ` with creating table and joining data	
----------------------------------------------------*/

CREATE TABLE completed_join_worldlanguage_allpairs
	(Country NVARCHAR(250),
	 First_official NVARCHAR(250),
	 LangName_1 NVARCHAR(250),
	 LangName_2 NVARCHAR(250),
	 Lexical_Similarity FLOAT,
	 );
	
/*---------------------------------------------------
 Insert Into our final joined dataset. Filtered to show:
  * ` Comparison of every country's first official language
	* ` compared to every other first official language
----------------------------------------------------*/
INSERT INTO completed_join_worldlanguage_allpairs
SELECT
	Country,
	First_official,
	LangName_1,
	LangName_2,
	Similarity AS Lexical_Similarity
FROM
	dup_wl
INNER JOIN all_language_pairs
	ON First_official = LangName_1
	WHERE LangName_2 IN (SELECT First_official FROM dup_wl)
Order BY Country;

/*---------------------------------------------------
 Final Data output -> Ready for Tableau Viz
----------------------------------------------------*/

SELECT *
FROM completed_join_worldlanguage_allpairs;
