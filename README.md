# Mnemonica

Mnemonica is a system for converting between arbitrary strings of data and a series of memorable English phrases. It leans toward visualization and personification as its primary mnemonic mechanism, favoring action scenes around an entity like an animal.

The primary use case is memorizing cryptocurrency private keys, often referred to as creating a "brain wallet." This system is inspired by [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) but adds extra mnemonic mechanisms:

(1) Words are selected for mental visualization, favoring concrete over abstract
(2) Phrases adhere to a repetitive grammar

The theory is that these additions will aid in longterm memorization of phrases.

Mnemonic also incorporates versioning slugs to ensure correct encoding/decoding as the lexicon evolves.


Phrases produced by Mnemonica take the form `[adjective] [noun] [verb] and [verb]`. For example:

Adjectives should be visual (colors, locations, textures)
Nouns should be well-known animals/characters/entities or otherwise personifiable.
Verbs should be actions a person/entity can do
The adverbs should be person-based (emotions, etc)

```
1. Northern impala runs and dances
2. Red tree sings and dies
3. Ancient willow stands and forgives
4. Nervous sparrow walks and bakes
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mnemonica'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mnemonica

## Usage

Produce a set of English phrases given input data (e.g. a cryptocurrency private key):

```
Mnemonica.encode(data)
```

`data` may be in the form of a hexidecimal (`ab29f3`), a binary string (`1001101`), or a decimal (`230938`).

Recover source data (e.g. a cryptocurrency private key) based on an English phrase generated using `encode` (above):

```
Mnemonica.decode(phrase)
```

Create a hash of source data so that a user may run `verify` to confirm they have memorized the correct code.

```
Mnemonica.hash(data)
Mnemonica.verify(phrase, hash)
```

Mnemonica can be used to encode, decode, and verify a phrase. Phrase verification ensures adherence to version lexicography as well checks it against a hash of the source data. This can be used for periodic quizzing of the user to fortify memory.

```
nemon encode [data]
nemon decode [phrases]

nemon hash [data]
nemon quiz [hash]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jcraigk/mnemonica.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
