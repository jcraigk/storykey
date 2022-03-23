# StoryKey

StoryKey is a system for converting between arbitrary strings of data and memorable English phrases. The primary use case is memorizing a cryptocurrency private key, colloquially referred to as "making a brain wallet". StoryKey is inspired by [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki), adding extra features:

(1) Encodes arbitrary length data from 1 to 512 bits
(2) Includes checksum for robustness
(3) Includes version slug to expose/guarantee accurate decoding
(4) Enforces a simple English grammar to drive semantic associations
(5) Lexicon is curated for mental visualization
(6) No keywords are repeated

A paragraph produced by StoryKey for a 256 bit string looks like this:

```
In Miami I saw
1. a Peruvian freeloader impress an orc,
2. a feeble grouse shroud a crab,
3. a Somalian tattooist betray Saruman,
4. a guilty punk lurk with Ahab,
5. a blushing Batman plagiarize an arsonist,
6. a Chinese goblin critique an aunt,
7. and a genius restore R2-D2
````

This paragraph can be deterministically decoded back into its binary source using the same version of StoryKey. The `version slug` is typically a well-known city, such as `Miami`. An exception will be raised if:
 * the `version slug` does not match the current version of StoryKey
 * any unrecognized `keywords` are provided
 * the embedded `checksum` does not match the expected value


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'story_key'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install story_key

## Usage

Produce a set of English phrases given input data (e.g. a cryptocurrency private key):

```
data = 'JA6ymjiUiuMBcaSek3x7AxDyWQhgUJWZZBvcWBy3f7Lt'
StoryKey.encode(data, format: :base58)
```

`data` may be in the form of a hexidecimal (`ab29f3`), a binary string (`1001101`), a decimal (`230938`), or a base58 string (`uMBca`).

Recover source data (e.g. a cryptocurrency private key) based on an English phrase generated using `encode` (above):

```
StoryKey.decode(story)
```

Create a hash of source data so that a user may run `verify` to confirm they have memorized the correct code.

```
StoryKey.quiz(hash)
```

TODO: Commandline

```
nemon encode [data]
nemon decode [phrases]

nemon hash [data]
nemon quiz [hash]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jcraigk/story_key.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
