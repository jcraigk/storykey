# TODO / IDEAS

* encode the "time" as last 4 bits of the checksum word. that reduces robustness of checksum to 1/64...use extra space in penultimate word for increasing that...so all phrases will encode a length of multiple of word size (270 for 257, for example, 9 checksum bits, 4 tail bits, )
for 256, we get 14 bits of checksum, no tail

* Eliminate repetition by removing words from the lexicon as the string is encoded. Would need to adjust for this when decoding (increment by the number of word types preceding current word to get actual decimal value). and we'd need to add additional words to accommodate...this adds a hard limit to the total length of data we can encode

* Incorporate version slug into checksum word and use that instead of version slug? Would be more secure and would eliminate something user would need to remember

* Colorize output highlighting the different words and their types. use emoji as well.
* Check for verbs that could also be nouns and vice versa - see if we can eliminate the biggest offendors - it should be clear what word type it is just by looking at the single word

* Expand formats to include base64, base58, base58check

* Zeitwerk?

Maybe...
* Use up max bitsize for checksum (so 10-19 chars), affecting second to last word as well in most cases
* Utilize personal knowledge by giving a questionnaire to user: musicians, sports figures, etc to adjust lexicons, then provide a bitmask for this along with version_slus so lead would be "In Miami at the Pier I saw" with Pier referring to specific set of lexicons to be used
* Quiz using hashes of rows and columns (security risk?)
* Rhythmic patterns?
* Haikus? Would require two haikus for 256. 7 bits per _syllable_ so so 2-syllable words would need large lexicons...
