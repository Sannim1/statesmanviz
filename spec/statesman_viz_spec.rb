RSpec.describe StatesmanViz do
  it "has a version number" do
    expect(StatesmanViz::VERSION).not_to be nil
  end

  describe ".generate" do
    let(:dummy_state_machine) { double("dummy_state_machine") }
    let(:states) { %i[idle fetching error] }
    let(:transitions) do
      {
        idle: %i[fetching],
        fetching: %i[idle error],
        error: %i[fetching]
      }
    end

    subject(:generate) { StatesmanViz.generate(dummy_state_machine) }

    it "generates a state machine diagram" do
      expect(dummy_state_machine).to receive(:states).and_return(states)
      expect(dummy_state_machine).to receive(:successors).and_return(transitions)

      expect { generate }.to change {
        File.exists?("/tmp/StatesmanViz/#{dummy_state_machine.to_s}.png")
      }.from(false).to(true)
    end

    context "for an invalid state machine class" do
      it "raises an error when states do not exist" do
        expect { generate }.to raise_error(ArgumentError, /must respond to `.states`/)
      end

      it "raises an error when transitions do not exist" do
        allow(dummy_state_machine).to receive(:states).and_return(states)
        expect { generate }.to raise_error(ArgumentError, /must respond to `.successors`/)
      end
    end
  end
end
