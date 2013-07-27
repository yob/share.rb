$LOAD_PATH.push File.join(__FILE__, "../..")
require "lib/share"
system("clear")
require "rspec"
require "shoulda-matchers"

RSpec.configure do |config|
  config.color_enabled = true
  # config.filter_run focus:true
end

poem = open("spec/data/jabberwocky.txt").read.split(/\s+/)
def random_word
  poem.shuffle.first
end
