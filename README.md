[![Gem Version](https://badge.fury.io/rb/story_key.svg)](https://badge.fury.io/rb/story_key)
![Gem Downloads](https://ruby-gem-downloads-badge.herokuapp.com/story_key?type=total)
[![Build Status](https://travis-ci.org/jcraigk/story_key.svg?branch=main)](https://travis-ci.org/jcraigk/story_key)
[![Test Coverage](https://api.codeclimate.com/v1/badges/6046413814d7f6417ce9/test_coverage)](https://codeclimate.com/github/jcraigk/story_key/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/6046413814d7f6417ce9/maintainability)](https://codeclimate.com/github/jcraigk/story_key/maintainability)


![Story Key Logo](https://user-images.githubusercontent.com/104095/160752597-45ab3b7b-a3a3-43ef-b546-9c163f389927.png)

| Gem version | Story setting |
|-------------|---------------|
| 0.1.0       | Miami         |


# StoryKey

StoryKey is a [Brainwallet](https://en.bitcoin.it/wiki/Brainwallet) inspired by [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki). It can be used to memorize private keys or any arbitrary string of data between 1 and 512 bits.

It uses three parts of English speech - adjectives, nouns, and verbs - to produce phrases that are sequenced into stories. Each story represents a lossless version of the original data, in a format that is easier for a human to remember.

Features:

1. Encodes arbitrary length keys from 1 to 512 bits (default 256)
2. Includes checksum to validate the story
3. Includes version slug to ensure accurate decoding
4. Presents a repeating English grammar to aid in memorization
5. Utilizes a lexicon curated for mental visualization
6. Avoids word repetition within the story
7. Provides interactive command-line recovery assistance

Each word of the story encodes 10 bits. The checksum length is variable based on the input size and space available in the last two words after appending for a 4-bit footer. Here are a few example key sizes along with their respective story and checksum sizes.

| Key bits | Story words | Checksum bits |
|----------|-------------|---------------|
| 64       | 8           | 12            |
| 128      | 14          | 8             |
| 192      | 21          | 14            |
| 256      | 27          | 10            |
| 384      | 40          | 12            |
| 512      | 53          | 14            |

An example key and its associated story are shown below:

Screenshot from terminal:
![Key/Story Example](https://user-images.githubusercontent.com/104095/160753139-e2a6fb07-a135-4e9e-8069-5c4eb2b5be0d.png)

Text:
```
Key:
2VD2SKZTu5JBh8XeuFYzd9zLAtfW2YKNEsTgf8bHS7Lz
Story:
In Miami I saw
1. a vile zombie overcome a harpy,
2. a pitiful Dustin Hoffman grumble at Henri Matisse,
3. a sleek physicist rush Pippin Took,
4. a sandy Gene Hackman decorate Epicurus,
5. a defensive osprey replicate a snob,
6. an exultant jurist attack Methuselah,
7. and Jack Sparrow quiz a bobcat.
````

This paragraph can be deterministically decoded back into its binary source using the same version of StoryKey. The `version slug` is typically a well-known city, such as `Miami`. During key recovery, an exception will be raised if:
 * the `version slug` does not match the current version of StoryKey
 * the embedded `checksum` does not match the expected value

### Visualization

When machine learning becomes less expensive, StoryKey stories may be converted to graphical panels similar to the [DALL-E Project](https://openai.com/blog/dall-e/). This will likely aid in the memorization process for some users.


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
StoryKey.decode(story:)
```


### Generate new key/story

Generate a new random key/story pair.

```
StoryKey.generate
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

The command line also features an interactive recovery tool to aid in converting a story back into its source key. Run `bin/storykey recover` to initiate the process.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jcraigk/story_key.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
