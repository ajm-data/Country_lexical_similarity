/*
SELECT * FROM all_language_pairs;
SELECT * FROM language_pairs;
SELECT * FROM WorldLanguage$;
SELECT * FROM world_languages;
*/

/*----------------------------------------------------
********** Create Tables *************
All language pairs in lexical_similarity data
All country, first_official language in WorldLanguage data
----------------------------------------------------*/

DROP TABLE IF EXISTS all_language_pairs;
CREATE TABLE all_language_pairs
	(LangName_1 NVARCHAR(250),	-- First language
	 LangName_2 NVARCHAR(250),  -- Second language for comparison
	 Similarity FLOAT,			-- Similarity between both languages
	 Robustness NVARCHAR(250)); -- Size of word groups used for similarity comparison
-- Append LangName_2 to LangName_1 with UNION
INSERT INTO all_language_pairs
	SELECT LangName_1, LangName_2, Similarity, Robustness
	FROM language_pairs
		UNION
	SELECT LangName_2, LangName_1, Similarity, Robustness
	FROM language_pairs;

DROP TABLE IF EXISTS world_languages;
CREATE TABLE world_languages 
	(Country NVARCHAR(250),
	 First_official NVARCHAR(250));
INSERT INTO world_languages
	SELECT 
		"Territory/Country",
		"1st_official"
	FROM WorldLanguage$;

/*----------------------------------------------------
********** Duplicate Tables *************
----------------------------------------------------*/
DROP TABLE IF EXISTS dup_lp;
SELECT *
INTO dup_lp -- duplicate of all_language_pairs
FROM all_language_pairs;

DROP TABLE IF EXISTS dup_wl;
SELECT *
INTO dup_wl -- duplicate world_languages
FROM world_languages;

/*---------------------------------------------------
 Use View to find the occurrences of languages
	not matching in 'all_language_pairs'.
	Refer to after updating 
----------------------------------------------------*/
DROP VIEW IF EXISTS v_unmatched;
CREATE VIEW v_unmatched AS
SELECT 
	Country,
	First_official,
	LangName_1
FROM dup_wl 
LEFT JOIN dup_lp
	ON First_official = LangName_1
WHERE LangName_1 IS NULL;

-- Query used for reference when cleaning/updating
SELECT * FROM v_unmatched
ORDER BY First_official;

/*---------------------------------------------------
  54 countries w/ unmatched First_official on LangName_1
  Arabic (21 NULL values)
  Standard Chinese or Mandarin (3 NULL values)
  26 different 1st_official languages with exactly (1 NULL value)
	* Could mean missing data in language pair table
----------------------------------------------------*/

/*---------------------------------------------------- 
********** ARABIC ***********
Find LangName_1 similar to 'Arabic'
Update First_official in dup_wl with matching langName_1
--------------------------------------------------------*/
SELECT DISTINCT(LangName_1)
FROM dup_lp
WHERE LangName_1 LIKE '%Arab%';

-- 3 types of Arabic: Egyptian, Moroccan, Standard
-- Update dup_wl First_official

UPDATE dup_wl
SET First_official = CASE WHEN Country = 'Egypt' THEN 'Egyptian Arabic'
					WHEN Country = 'Morocco' THEN 'Moroccan Arabic'
					WHEN First_official = 'Arabic' THEN 'Standard Arabic'
					ELSE First_official
					END;
SELECT * FROM dup_wl;

/*---------------------------------------------------- 
********** Chinese ***********
Find LangName_1 similar to 'Chinese' OR 'Cantonese'
Update First_official in dup_wl with matching langName_1
--------------------------------------------------------*/
SELECT DISTINCT(LangName_1)
FROM dup_lp
WHERE LangName_1 LIKE '%Chinese%' OR
	  LangName_1 LIKE '%Canton%'; 

-- 2 types of Chinese: Mandarin & Yue(cantonese)
-- Find Countries with spoken chinese

SELECT *
FROM dup_wl
WHERE First_official LIKE '%Chinese%' OR
	  First_official LIKE '%Canton%';

UPDATE dup_wl
SET First_official = CASE WHEN
		Country = 'China' THEN 'Mandarin Chinese'
		WHEN Country = 'Hong Kong S.A.R.' THEN 'Yue Chinese' -- Cantonese
		WHEN Country = 'Singapore' THEN 'Mandarin Chinese'
		WHEN Country = 'Taiwan' THEN 'Mandarin Chinese'
		ELSE First_official
	END;

/*---------------------------------------------------- 
********** Chinese ***********
Find LangName_1 similar to 'Asian' First_official
Update First_official in dup_wl with matching langName_1
--------------------------------------------------------*/
SELECT * FROM v_unmatched
ORDER BY First_official;

SELECT DISTINCT(LangName_1)
FROM dup_lp
WHERE LangName_1 LIKE ('%Mong%')
   OR LangName_1 LIKE ('%Indo%')
   OR LangName_1 LIKE ('%Malay%')
   OR LangName_1 LIKE ('%Burm%')
   OR LangName_1 LIKE ('%Fili%')
   OR LangName_1 LIKE ('%Taga%');

UPDATE dup_wl
SET First_official = CASE WHEN Country = 'Myanmar' THEN 'Burmese'
					WHEN Country = 'Philippines' THEN 'Tagalog'
					WHEN Country = 'Indonesia' THEN 'Indonesian'
					WHEN Country = 'Malaysia' THEN 'Malay'
					WHEN Country = 'Mongolia' THEN 'Mongolian'
					ELSE First_official
				END;

/*---------------------------------------------------- 
********** Europe ***********
Find LangName_1 similar to 'European' First_official
Update First_official in dup_wl with matching langName_1
--------------------------------------------------------*/
SELECT * FROM v_unmatched
ORDER BY Country;

SELECT DISTINCT(LangName_1)
FROM dup_lp
WHERE LangName_1 LIKE ('%Greek%')
   OR LangName_1 LIKE ('%Bos%')
   OR LangName_1 LIKE ('%Eston%')
   OR LangName_1 LIKE ('%Latv%')
   OR LangName_1 LIKE ('%Mold%')
   OR LangName_1 LIKE ('%Mont%')
   OR LangName_1 LIKE ('%Norw%')
   OR LangName_1 LIKE ('%Serb%');

-- Update 'Modern Greek' -> 'Greek' AND 'Norwegian Nynorsk' -> 'Norwegian'
-- Update language_pairs so that first_official maintains the name 'Greek' & 'Norwegian'
UPDATE dup_lp
SET LangName_1 = CASE WHEN LangName_1 = 'Modern Greek' THEN 'Greek'
				WHEN LangName_1 = 'Norwegian Nynorsk' THEN 'Norwegian'
				ELSE LangName_1
				END;

/*---------------------------------------------
***** Missing Values Brute Force Search *****
Looking for different names of the same language
	and potential spelling differences 
----------------------------------------------*/
SELECT DISTINCT(LangName_1) 
FROM dup_lp
WHERE LangName_1 LIKE '%Azer%' OR -- NONE
	  LangName_1 LIKE '%Bos%' OR -- NONE
	  LangName_1 LIKE '%creo%' OR -- Guad creole French / Jamaican Creole eng?
	  LangName_1 LIKE '%Eston%' OR -- NONE
	  LangName_1 LIKE '%Green%' OR -- NONE
	  LangName_1 LIKE '%Kirun%' OR -- NONE
	  LangName_1 LIKE '%Bant%' OR -- NONE
	  LangName_1 LIKE '%Kyrg%' OR -- = 'Kirghiz'
	  LangName_1 LIKE '%Kirg%' OR
	  LangName_1 LIKE '%Latv%' OR -- NONE
	  LangName_1 LIKE '%Marsh%' OR -- NONE
	  LangName_1 LIKE '%pidgin%' OR -- NONE
	  LangName_1 LIKE '%Mold%' OR -- NONE
	  LangName_1 LIKE '%Monten%' OR -- NONE
	  LangName_1 LIKE '%Naur%' OR -- 'Nauru'
	  LangName_1 LIKE '%Niuean%' OR -- NONE
	  LangName_1 LIKE '%Serb%' OR -- NONE
	  LangName_1 LIKE '%Sotho%' OR -- = 'Southern Sotho'
	  LangName_1 LIKE '%Swah%' OR -- NONE [?]
	  LangName_1 LIKE '%Kiswa%' OR -- NONE
	  LangName_1 LIKE '%Tong%' OR -- = 'Tonga'
	  LangName_1 LIKE '%Tuva%' OR -- = 'Tuvalu'
	  LangName_1 LIKE '%Uzbek%';  -- NONE

-- Update LangName_1 to match first_official
UPDATE dup_lp
SET LangName_1 = CASE WHEN LangName_1 = 'Tonga' THEN 'Tongan'
				WHEN LangName_1 = 'Tuvalu' THEN 'Tuvaluan'
				WHEN LangName_1 = 'Kirghiz' THEN 'Kyrgyz'
				WHEN LangName_1 = 'Southern Sotho' THEN 'Sotho'
				WHEN LangName_1 = 'Nauru' THEN 'Nauruan'
				ELSE LangName_1
				END;
-- Query the VIEW v_unmatched

SELECT * FROM v_unmatched
ORDER BY Country;

/*---------------------------------------------------------
**** 16 NULL values in LangName_1 due to lack of data ****
Azerbaijani Bosnian Kirundi Estonian Greenlandic Latvian
Marshallese Moldovan Montenegrin Niuean Serbian Creole 
Melanesian pidgin Swahili Uzbek Creole
-----------------------------------------------------------*/

/*------------------------------------------
***Produce final data asset***
Only include comparisons of first_official languages
----------------------------------------------*/

DROP TABLE IF EXISTS final_data_asset;
CREATE TABLE final_data_asset 
	(Country NVARCHAR(250),
	 First_official NVARCHAR(250),
	 LangName_1 NVARCHAR(250),	-- First language
	 LangName_2 NVARCHAR(250),  -- Second language for comparison
	 Lexical_Similarity FLOAT);			-- Similarity between both languages


INSERT INTO final_data_asset
SELECT
	Country,
	First_official,
	LangName_1,
	LangName_2,
	Similarity AS Lexical_Similarity
FROM
	dup_wl
INNER JOIN dup_lp
	ON First_official = LangName_1
	WHERE LangName_2 IN (SELECT First_official FROM dup_wl) -- Only includes first_official languages
Order BY Country;

-- Final data asset
SELECT * FROM final_data_asset
ORDER BY Country;