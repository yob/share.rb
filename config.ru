#
# An example rack config file. Boot the server like so:
#
#   bundle exec thin -R config.ru start
#
# .. and then point your browser at the address thin prints out. Probably
# something like http://127.0.0.1:3000
#

$LOAD_PATH.unshift File.dirname(__FILE__) + "/lib"
require 'share'

class WebApp
  def call(env)
    [200, { 'Content-Type' => 'text/html' }, <<EOF
<html><head>
<script>
  function init() {
    function log(msg) { document.getElementById('log').innerHTML += msg + '<br>'; }
    var socketUri = 'ws://' + document.location.host + '/socket';
    log('Socket URI: ' + socketUri);
    var socket = new WebSocket(socketUri);
    socket.onopen = function(e) {
      log('onopen');
      socket.send('Is there anybody out there?');
      log('sent message');
    };
    socket.onclose = function(e) {
      log('onclose; code = ' + e.code + ', reason = ' + e.reason);
    };
    socket.onerror = function(e) {
      log('onerror');
    };
    socket.onmessage = function(e) {
      log('onmessage; data = ' + e.data);
    };
  }
</script>
</head><body onload='init();'>
  <h1>Serving WebSocket and normal Rack app on the same port</h1>
  <p id='log'></p>
</body></html>
EOF
    ]
  end
end

repository = Share::Repo.new

map '/socket' do
  run Share::WebSocketApp.new(repository)
end

map '/' do
  run WebApp.new
end
