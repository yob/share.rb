share.rb
========

port of sharejs server to Ruby ( rack/thin )

# Example Server

## Run this

    git clone https://github.com/yob/share.rb.git
    bundle
    bundle exec thin -R config.ru start

## Browse to

    http://localhost:3000/

# TODO

* persistence
* JSON doc type
* if client provides a name during auth, add it to meta data of each op
* browserchannel?
* puma/threads instead of thin/eventmachine?
* move example app into a separate gem
