[![Gem Version](https://badge.fury.io/rb/story_key.svg)](https://badge.fury.io/rb/story_key)
![Gem Downloads](https://ruby-gem-downloads-badge.herokuapp.com/story_key?type=total)
[![Build Status](https://travis-ci.org/jcraigk/story_key.svg?branch=main)](https://travis-ci.org/jcraigk/story_key)
[![Test Coverage](https://api.codeclimate.com/v1/badges/6046413814d7f6417ce9/test_coverage)](https://codeclimate.com/github/jcraigk/story_key/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/6046413814d7f6417ce9/maintainability)](https://codeclimate.com/github/jcraigk/story_key/maintainability)


![Story Key Logo](https://user-images.githubusercontent.com/104095/160752597-45ab3b7b-a3a3-43ef-b546-9c163f389927.png)

| Gem Version | City  |
|-------------|-------|
| 0.1.0       | Miami |


# StoryKey

StoryKey is a [Brainwallet](https://en.bitcoin.it/wiki/Brainwallet) inspired by [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki). It converts an arbitrary string of data, such as a cryptocurrency private key, into an English paragraph intended for longterm human memory. It also assists in decoding the story back into its original form.

Each story is provided in two formats:
* Humanized
 * Version header ("In Miami I saw")
 * Enumerated phrases
 * Colorized parts of speech (adjectives, verbs, nouns)
 * Grammatical filler (articles, prepositions, conjunctions, punctuation)
* Tokenized
 * ordered list of unique tokens
 * space-delimited lowercase alphanumeric/dash
 * useful as a seed phrase for generating derivative keys

Features:
* Encodes arbitrary length keys from 1 to 512 bits (default 256)
* Includes checksum for integrity
* Includes version slug to ensure accurate decoding
* Uses a repeating English grammar to aid in mnemonics
* Uses a lexicon curated for mental visualization
* Avoids word repetition
* Provides interactive command-line recovery

Each token of the story (word or compound) encodes 10 bits. The checksum length is variable based on the input size and space available in the last two tokens after accounting for a 4-bit footer. Here are a few example key sizes along with their respective story and checksum sizes.

| Key bits | Story tokens | Checksum bits |
|----------|--------------|---------------|
| 64       | 8            | 12            |
| 128      | 14           | 8             |
| 192      | 21           | 14            |
| 256      | 27           | 10            |
| 384      | 40           | 12            |
| 512      | 53           | 14            |

An example key and its associated story and seed phrase are shown below.

Screenshot from terminal:
![Key/Story Example](https://user-images.githubusercontent.com/104095/161372021-1edb5999-453d-453a-a7bb-d2fc2bcc3120.png)

Text:
```
Key:
CH8krjSZpGFmxnKo9QPqQEd9oMUkXnLcUhhEQFLrGCtg
Story:
In Miami I saw
1. a pensive Ellen Ripley surpass a musician,
2. an unhappy pug drink vodka with a dove,
3. an opulent Dante Alighieri diagnose Huckleberry Finn,
4. a frantic sister eat pretzels with Mozart,
5. a cunning meerkat trim a balloonist,
6. a rich ocelot step to John Wayne,
7. and a civilian convict a locust.
Seed Phrase:
pensive ellen-ripley surpass musician unhappy pug drink-vodka dove opulent dante-alighieri diagnose huckleberry-finn frantic sister eat-pretzels mozart cunning meerkat trim balloonist rich ocelot step john-wayne civilian convict locust
````

This paragraph or seed phrase can be deterministically decoded back into its original format using the same version of StoryKey. The `version slug` is typically a well-known city, such as `Miami`. During key recovery, an exception will be raised if:
 * the `version slug` does not match the current version of StoryKey
 * the embedded `checksum` does not match the expected value


### Lexicon Curation

The lexicon was selected using the following criteria:

* Anthropomorphism. All parts of speech - adjective, noun, and verb - must fit logically when composed into phrases. To accommodate, entries were selected based on how closely they could produce a mental image of commonly known anthropomorphic entities interacting with one another. To produce enough verbs, compound actions such as "eat breakfast" were also used.
  * Adjectives: personal physical qualities, moods, colors, textures
  * Nouns: famous people/characters, professions, animals
  * Verbs: physical actions connecting subject/object, favoring transitive, sometimes compound
* Visualization. Entries should be concrete vs abstract and convey vivid mental imagery.
* Cultural acceptability. Reject sexually suggestive and other controversial imagery.
* Eliminate similar base words across parts of speech.
* Balance brevity with clarity.


### Graphical Visualization

When AI becomes more common, StoryKey stories may be converted to graphical panels similar to the [DALL-E Project](https://openai.com/blog/dall-e/). This will likely aid in the memorization process for many users.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'story_key'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:
```
$ gem install story_key
```


## Usage

This library may be used by calling Ruby methods or directly from the command line.


### Ruby Usage

After installing the gem, you may run `bin/console` or `require` the gem in your own project.


### Encode key => story

Produce an English paragraph given input data (e.g. a cryptocurrency private key):

```
data = 'JA6ymjiUiuMBcaSek3x7AxDyWQhgUJWZZBvcWBy3f7Lt'
StoryKey.encode(key:)
```

`key` may be in the form of a hexidecimal (`ab29f3`), a binary string (`1001101`), a decimal (`230938`), or a base58 string (`uMBca`). If not in the default base58, `format` must be provided.


### Decode story => key

Recover source data (e.g. a cryptocurrency private key) based on the English paragraph:

```
3.1.1# StoryKey.decode(story: 'In Miami I saw an official Benjamin Franklin transport Matt Damon')
 => "4NTM"
```


### Generate new key/story

Generate a new random key/story pair.

```
3.1.1# StoryKey.generate
 =>
["4eqfoXzMDyqQW6p8zAQj7c8KkynK5K2BW6D5Vfp7xCaQ",
 #<struct StoryKey::Story
  text=
   "In Miami I saw a dim Balrog eat hummus with an appraiser, a facetious scholar play badminton with an economist, a witty uncle insure Bruce Willis, an appreciative dolphin blare at a cyclist, a blissful James Bond undercut a connoisseur, a green Hugh Jackman eat cheese with a bison, and Elvis Presley snorkel with a counselor.",
  humanized=
   "In \e[31mMiami\e[0m I saw\n1. a \e[36mdim\e[0m \e[33mBalrog\e[0m \e[35meat hummus\e[0m with an \e[33mappraiser\e[0m,\n2. a \e[36mfacetious\e[0m \e[33mscholar\e[0m \e[35mplay badminton\e[0m with an \e[33meconomist\e[0m,\n3. a \e[36mwitty\e[0m \e[33muncle\e[0m \e[35minsure\e[0m \e[33mBruce Willis\e[0m,\n4. an \e[36mappreciative\e[0m \e[33mdolphin\e[0m \e[35mblare\e[0m at a \e[33mcyclist\e[0m,\n5. a \e[36mblissful\e[0m \e[33mJames Bond\e[0m \e[35mundercut\e[0m a \e[33mconnoisseur\e[0m,\n6. a \e[36mgreen\e[0m \e[33mHugh Jackman\e[0m \e[35meat cheese\e[0m with a \e[33mbison\e[0m,\n7. and \e[33mElvis Presley\e[0m \e[35msnorkel\e[0m with a \e[33mcounselor\e[0m.",
  tokenized=
   "dim balrog eat-hummus appraiser facetious scholar play-badminton economist witty uncle insure bruce-willis appreciative dolphin blare cyclist blissful james-bond undercut connoisseur green hugh-jackman eat-cheese bison elvis-presley snorkel counselor">]
```


## Command Line

Invoke the command line interface by running `bin/storykey`. It has several options, including the Ruby methods mentioned above.

```
StoryKey commands:
  storykey decode [STORY]  # Decode a story passed as an argument or from a file
  storykey encode [KEY]    # Encode a key passed as an argument or from a file
  storykey help [COMMAND]  # Describe available commands or one specific command
  storykey new [BITSIZE]   # Create a new key/story (default 256 bits, max 512)
  storykey recover         # Decode a story interactively
```

The command line also features an interactive recovery tool to aid in converting a story back into its source key. Run `bin/storykey recover` to initiate the process:

![Key/Story Example](https://user-images.githubusercontent.com/104095/161376334-4a591100-e3fc-41ce-b931-4773bebc23fd.png)


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jcraigk/story_key.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
