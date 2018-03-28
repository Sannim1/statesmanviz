require "statesman_viz/version"
require "graphviz"

module StatesmanViz
  class << self
    def generate(state_machine_class, output_file_path: nil)
      unless state_machine_class.respond_to?(:states)
        raise ArgumentError, "State machine class must respond to `.states`"
      end
      unless state_machine_class.respond_to?(:successors)
        raise ArgumentError, "State machine class must respond to `.successors`"
      end

      state_graph = GraphViz.new( :G, :type => :digraph )

      node_map = {}
      state_machine_class.states.each do |state|
        node_map[state] = state_graph.add_nodes(state)
      end

      state_machine_class.successors.each do |from_state, to_states|
        to_states.each do |to_state|
          state_graph.add_edges(node_map[from_state], node_map[to_state])
        end
      end

      output_file_path = output_file_path || "#{state_machine_class.to_s}.png"

      state_graph.output( :png => output_file_path )
    end
  end
end
