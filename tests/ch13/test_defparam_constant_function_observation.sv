/*
:name: test_defparam_constant_function_observation
:description: A parameter override provides a control for a defparam affected constant call
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_defparam_constant_function_observation.expected
*/
module function_constant_probe #(parameter int BASE=5, parameter int DERIVED=BASE+1)
    (output wire [31:0] direct_value, indirect_value);
  function automatic int direct(input int addend);
    return BASE + addend;
  endfunction
  function automatic int indirect(input int addend);
    return DERIVED + addend;
  endfunction
  localparam int DIRECT = direct(4);
  localparam int INDIRECT = indirect(4);
  assign direct_value = DIRECT;
  assign indirect_value = INDIRECT;
endmodule

module test_defparam_constant_function_observation;
  wire [31:0] direct_value, indirect_value;
  function_constant_probe #(.BASE(7)) stable(direct_value, indirect_value);
`ifdef OBSERVE_DEFPARAM
  wire [31:0] affected_direct, affected_indirect;
  function_constant_probe affected(affected_direct, affected_indirect);
  defparam affected.BASE = 11;
`endif
  initial begin
    #1 $display("explicit override=%0d,%0d", direct_value, indirect_value);
`ifdef OBSERVE_DEFPARAM
    $display("defparam results=%0d,%0d", affected_direct, affected_indirect);
`endif
    $finish(0);
  end
endmodule
