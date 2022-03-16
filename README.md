# Peartree

Peartree is a system for converting between arbitrary strings of data and a series of memorable English phrases. Its grammar and lexicon is curated for concreteness and personification, supporting mental visuzliation.

The primary use case is memorizing cryptocurrency private keys, often referred to as creating a "brain wallet." This system is inspired by [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) but adds extra features:

(1) Encode arbitrary length strings, supporting popular formats
(2) Includes 10-bit checksum word to fortify phrases
(3) Includes version slug to guarantee accurate decoding
(4) Lexicon curated for mental visualization
(5) Phrases adhere to a repeating grammar

Phrases produced by Peartree take the following form:

```
In [version slug] at [bit entropy of last word] I saw
1. [adjective] [noun] [verb] and [verb]
2. [adjective] [noun] [verb (checksum)]
````

For example

```
In Miami at 6pm I saw
1. A pretty body flow and list
2. A blushing wedding flow
```

The `version slug` is typically a well-known city, such as `Miami`. The `bity entropy of last word` contains a digit that refers to the number of bits contained in the last word (allowing arbitrary length string encoding). The `checksum` is an additional word added to fortify the whole phrase.

This paragraph can be deterministically decoded using the same version of Peartree.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'peartree'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install peartree

## Usage

Produce a set of English phrases given input data (e.g. a cryptocurrency private key):

```
Peartree.encode(data)
```

`data` may be in the form of a hexidecimal (`ab29f3`), a binary string (`1001101`), or a decimal (`230938`).

Recover source data (e.g. a cryptocurrency private key) based on an English phrase generated using `encode` (above):

```
Peartree.decode(phrase)
```

Create a hash of source data so that a user may run `verify` to confirm they have memorized the correct code.

```
Peartree.hash(data)
Peartree.verify(phrase, hash)
```

Peartree can be used to encode, decode, and verify a phrase. Phrase verification ensures adherence to version lexicography as well checks it against a hash of the source data. This can be used for periodic quizzing of the user to fortify memory.

```
nemon encode [data]
nemon decode [phrases]

nemon hash [data]
nemon quiz [hash]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jcraigk/peartree.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
