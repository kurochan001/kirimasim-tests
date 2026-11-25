/*
:name: test_class_property_before_initializer_observation
:description: A base constructor observes the argument before a derived property initializes
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_property_before_initializer_observation.expected
*/
module test_class_property_before_initializer_observation;
  class base;
    int captured;
    function new(int argument);
      captured = argument;
    endfunction
  endclass

  class derived extends base;
    int initialized = 29;
    function new();
`ifdef OBSERVE_BEFORE_INITIALIZER
      super.new(initialized);
`else
      super.new(7);
`endif
    endfunction
  endclass

  initial begin
    derived value;
    $display("before constructor");
    value = new;
    $display("base argument=%0d final property=%0d", value.captured, value.initialized);
    $finish(0);
  end
endmodule
