# Elasticsearch::Model::Extensions

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'elasticsearch-model-extensions'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install elasticsearch-model-extensions

## Usage

TODO: Write usage instructions here

## Running examples

With Elasticsearch installed, you can run examples configured with an ES instance started on the port 9250 and AR connected to sqlite:

    $ bundle exec irb -I spec -r example/articles_with_comments
    (A bunch of log output here)
    irb(main):001:0> Article.search('Comment1')

## Contributing

1. Fork it ( https://github.com/[my-github-username]/elasticsearch-model-extensions/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
