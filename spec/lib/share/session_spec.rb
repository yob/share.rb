require 'spec_helper'

# unit-ish specs for Share::Session. See extra specs in the integration
# directory for more session related specs.
#
describe Share::Session do
  it "generates a secure random id" do
    Share::Session.new(nil).id.class.should == String
    Share::Session.new(nil).id.length.should == 32
  end

  describe "#handshake_response" do
    let!(:session) { Share::Session.new(nil) }

    it "should return the current response" do
      session.handshake_response.should == {auth: session.id}
    end
  end
end
