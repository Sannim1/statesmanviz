require "statesman_viz/version"
require "graphviz"
require "fileutils"

module StatesmanViz
  class << self
    def configure
      yield config
    end

    def config
      @config ||= Configuration.new
    end

    def generate(state_machine_class)
      unless state_machine_class.respond_to?(:states)
        raise ArgumentError, "State machine class must respond to `.states`"
      end
      unless state_machine_class.respond_to?(:successors)
        raise ArgumentError, "State machine class must respond to `.successors`"
      end

      state_graph = GraphViz.new(:G, type: :digraph)

      node_map = {}
      state_machine_class.states.each do |state|
        state = state.to_s
        node_map[state] = state_graph.add_nodes(state)
      end

      state_machine_class.successors.each do |from_state, to_states|
        from_state = from_state.to_s
        to_states.each do |to_state|
          to_state = to_state.to_s
          state_graph.add_edges(node_map[from_state], node_map[to_state])
        end
      end

      output_dir = config.output_directory
      FileUtils.mkdir_p(output_dir)

      output_file_name = File.join(output_dir, "#{state_machine_class}.png")
      state_graph.output(png: output_file_name)
      
      output_file_name
    end
  end

  class Configuration
    attr_accessor :output_directory

    def initialize
      @output_directory = "/tmp/StatesmanViz"
    end
  end
end
