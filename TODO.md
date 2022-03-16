# TODO / IDEAS

* Colorize output highlighting the different words and their types. use emoji as well.
* Check for verbs that could also be nouns and vice versa - see if we can eliminate the biggest offendors - it should be clear what word type it is just by looking at the single word
* Incorporate lexicon sha into checksum word and use that instead of version slug? Would be more secure and would eliminate something user would need to remember
* Omit time part if input is default priv key length (256 bit)
* Put hard limit on input size (max 10 phrases)
* If single phrase, do not enumerate
* If the last phrase consists of a single word, make it a noun
 * Is there a more elegant way to handle this and also the connector words?
 * Support multiple templates?
* Eliminate repetition by removing words from the lexicon as the string is encoded. Would need to adjust for this when decoding (increment by the number of word types preceding current word to get actual decimal value). and we'd need to add additional words to accommodate...this adds a hard limit to the total length of data we can encode
* Expand formats to include base64, base58, base58check

Maybe...
* Utilize personal knowledge by giving a questionnaire to user: musicians, sports figures, etc to adjust lexicons, then provide a bitmask for this along with version_slus so lead would be "In Miami at the Pier I saw" with Pier referring to specific set of lexicons to be used
* Quiz using hashes of rows and columns (security risk?)
* Rhythmic patterns?
