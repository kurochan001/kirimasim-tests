/*
:name: test_real_output_variables_propagate_through_two_port_boundaries
:description: An output variable of real type propagates the same changes through one or two module port connections
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.2 23.2.2.3 6.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_output_variables_propagate_through_two_port_boundaries.expected
*/
module real_chain_source #(parameter realtime INITIAL_VALUE = 0.25)
                         (output var real value, mirror, output var int sequence_id);
  timeunit 10ns;
  timeprecision 1ns;
  initial begin
    value = INITIAL_VALUE;
    mirror = -INITIAL_VALUE;
    sequence_id = 1;
    #0.3;
    value = -1.5;
    mirror = 1.5;
    sequence_id = 2;
    #0.4;
    value = 2.75;
    mirror = -2.75;
    sequence_id = 3;
  end
endmodule

module real_chain_middle(output var real value, mirror, output var int sequence_id);
  timeunit 1ns;
  timeprecision 100ps;
  real_chain_source #(.INITIAL_VALUE(0.25)) nested(value, mirror, sequence_id);
endmodule

module test_real_output_variables_propagate_through_two_port_boundaries;
  timeunit 1ps;
  timeprecision 1ps;
  real shallow, deep, shallow_mirror, deep_mirror;
  int shallow_id, deep_id;
  real_chain_source direct(shallow, shallow_mirror, shallow_id);
  real_chain_middle middle(deep, deep_mirror, deep_id);

  task automatic sample();
    $display("t=%0d real=%0.2f/%0.2f/%0.2f mirror=%0.2f/%0.2f integer=%0d/%0d", $time, shallow,
             middle.nested.value, deep, shallow_mirror, deep_mirror, shallow_id, deep_id);
  endtask

  initial begin
    #1 sample();
    #3000 sample();
    #4000 sample();
    $finish(0);
  end
endmodule
