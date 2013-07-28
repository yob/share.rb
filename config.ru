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

repository = Share::Repo.new

map '/socket' do
  run Share::WebSocketApp.new(repository)
end

map '/' do
  run Share::ExampleApp.new
end
