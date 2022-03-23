# TODO / IDEAS

* Use markup to indicate extra words and support multiple words like "van Gogh" and "Marge Simpson". Dictionary should combine/downcase the primary part for the key. When decoding, check for multi-word match first.

* Fuzzy finder auto-complete for recovery process

* Ask for input bitsize when encoding and left-pad the binary string with zeros if converting (add this to coercer). Also verify bitsize of input InvalidInputSize (must be <= specified)

* Use https://openai.com/blog/dall-e/ or similar to generate images as cognitive aids


MAYBE
* Incorporate version slug into checksum word and use that instead of version slug? Would eliminate a word the user would need to remember, but would limit number of versions possible, and hide away the slug itself (good or bad?). it's nice to have the place to start the story...
* Check for verbs that could also be nouns and shared bases in general
* Zeitwerk?
* Utilize personal knowledge by providing targeted lexicons: musicians, sports figures, then provide a bitmask for this along with version_slug so lead would be "In Miami at the Pier I saw" with Pier referring to specific set of lexicons to be used OR just entirely different place.
* Syllabic patterns / Haikus? Would require two haikus for 256. 7 bits per _syllable_ so 2-syllable words would need large lexicons
