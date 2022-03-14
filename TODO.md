# TODO / IDEAS

* Refactor lexicon to be a single hash with `word => int`, decoding can then occur on any template
* Add checksum word(s) to end of phrase? tradeoffs?
* If the last phrase consists of a single word, make it a noun
 * Is there a more elegant way to handle this and also the connector words?
 * Support multiple templates?
* Eliminate repetition by removing words from the lexicon as the string is encoded. Would need to adjust for this when decoding (increment by the number of word types preceding current word to get actual decimal value). and we'd need to add additional words to accommodate...this adds a hard limit to the total length of data we can encode
* Expand formats to include base64, base58, base58check

Maybe...
* Utilize personal knowledge by giving a questionnaire to user: musicians, sports figures, etc to adjust lexicons, then provide a bitmask for this along with version_slus so lead would be "In Miami at the Pier I saw" with Pier referring to specific set of lexicons to be used
* Quiz using hashes of rows and columns (security risk?)
* Rhythmic patterns?
