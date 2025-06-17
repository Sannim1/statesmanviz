RSpec.describe StatesmanViz do
  it "has a version number" do
    expect(StatesmanViz::VERSION).not_to be nil
  end

  describe ".configure" do
    it "allows configuration of output directory" do
      StatesmanViz.configure do |config|
        config.output_directory = "/tmp/custom_dir"
      end
      expect(StatesmanViz.config.output_directory).to eq("/tmp/custom_dir")
    end
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

    before do
      StatesmanViz.configure do |config|
        config.output_directory = "/tmp/StatesmanViz"
      end
    end

    subject(:generate) { StatesmanViz.generate(dummy_state_machine) }

    it "generates a state machine diagram" do
      expect(dummy_state_machine).to receive(:states).and_return(states)
      expect(dummy_state_machine).to receive(:successors).and_return(transitions)

      expect { generate }.to change {
        File.exist?("/tmp/StatesmanViz/#{dummy_state_machine}.png")
      }.from(false).to(true)
    end

    it "returns the output file path" do
      allow(dummy_state_machine).to receive(:states).and_return(states)
      allow(dummy_state_machine).to receive(:successors).and_return(transitions)
      
      expect(generate).to eq("/tmp/StatesmanViz/#{dummy_state_machine}.png")
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
