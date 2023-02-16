# Country_lexical_similarity
Comparing the 'lexical similarities' between first official languages

# Citation
Gábor Bella, Khuyagbaatar Batsuren, and Fausto Giunchiglia. A Database and Visualization of the Similarity of Contemporary Lexicons. 24th International Conference on Text, Speech, and Dialogue. Olomouc, Czech Republic, 2021.

# What is lexical similarity?
According to the definition by The Ethnologue, it is ‘the percentage of lexical similarity between two linguistic varieties is determined by comparing a set of standardized wordlists and counting those forms that show similarity in both form and meaning.’

In other words, it is a single number between 0 and 100 that gives a measure of how much the vocabularies of two languages are similar.

# What is it for?
In comparative linguistics (lexicostatistics, glottochronology) this measure has been used to infer and verify hypotheses of linguistic phylogeny, i.e. the historical relatedness of languages. In contrast, our database has a synchronic focus and is more adapted to uses in modern language. We expect it to be usable for computational tasks, such as to estimate the cross-lingual reusability of language resources, for tasks such as bilingual lexicon induction or cross-lingual transfer.

# How is it different from other similarity databases?
All approaches are fundamentally based on counting cognate pairs between lexicons: words of common origin that often sound similar and mean similar things, such as the English letter, the French lettre, or the Italian lettera. Simply put, the more cognates are found between two languages, the more similar the lexicons.

As far as differences go, databases used in lexicostatistics, such as ASJP, use a small number (typically less than 100) of carefully selected words with equivalent meanings in each language studied. The word meanings are deliberately chosen from core vocabularies, and comparisons are made strictly on phonetic representations, sometimes also taking historical sound changes into account.

Our data, on the other hand, was obtained from the large, contemporary, general-language lexicons of the UKC, and is therefore more representative of contemporary language. As a source of cognate pairs, we used the CogNet database that contains over 8 million cognate pairs. CogNet is based on a more computationally-oriented definition of cognacy that includes loanwords (such as sumo) but is more strict on meaning equivalence. However, we do exclude words that are highly domain-specific (e.g. Staffordshire Bullterrier or myocardial infarction) as such domain terms are beyond the scope of general lexicons and would have introduced a strong bias into our results.
