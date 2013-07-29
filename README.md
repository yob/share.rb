share.rb
========

port of sharejs server to Ruby ( rack/thin )

## Usage

To start a share.rb server that's ready to accept connections:

    git clone https://github.com/yob/share.rb.git
    bundle
    bundle exec thin -R config.ru start

## Client

This is tested to work with the 0.5.0 release of client code from
http://sharejs.org.

First load the client side sharejs libraries:

    <script src="/js/share.uncompressed.js" type="text/javascript"></script>
    <script src="/js/textarea.js" type="text/javascript"></script>

Then create a textarea to attach to a share.rb document:

    <textarea id='pad'></textarea>

Finally, attach the textarea:

    <script>
        var options = {
          origin = 'ws://' + document.location.host + '/socket',
          authentication: '123456'
        }
        sharejs.open('document-id', 'text', options, function(error, doc) {
          var elem = document.getElementById('pad');
          doc.attach_textarea(elem);
        });
      }
    </script>

At this stage, websockets is the only transport protocol supported, which means
you will need to use a modern-ish client. Hopefully browserchannel will be an
option soon, adding support for all major browsers.

The value for authentication can be anything you like. At this stage the server
ignores it, but eventually the server will be configurable to accept or deny the
connection.

## Demo

Getting all the pieces lined up takes a bit of work, so there's a demo app you
might like to try to see how it all works.

    git clone https://github.com/yob/share-rb-demo.git
    cd share-rb-demo
    bundle
    bundle exec thin -R config.ru start

Then open your browser and load:

    http://127.0.0.1:3000/

## TODO

* persistence
* JSON doc type
* if client provides a name during auth, add it to meta data of each op
* browserchannel?
* puma/threads instead of thin/eventmachine?
