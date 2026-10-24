/*
:name: test_variable_initializer_not_continuous
:description: An assignment in a variable declaration only initializes the variable, so later procedural writes stick and later changes of its operands do not reach it, while a net declaration assignment keeps driving the net (IEEE 1800-2023 Section 6.5)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.5 6.8 10.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_variable_initializer_not_continuous.expected
*/
// IEEE 1800-2023 §6.5: unlike a net, a variable cannot have a continuous
// assignment in its declaration; an assignment there is an initialization of
// the variable (6.8), counted as a procedural assignment. A net declaration
// assignment, in contrast, is a continuous assignment (10.3.1).
// v is a static variable initialized to 10 and later written procedurally: the
// write takes effect and stays. w is a net whose declaration assignment
// follows src. In the automatic function twice, the initializer of y is
// evaluated once on entry from k; changing k afterwards does not change y.

module test_variable_initializer_not_continuous;
  logic [7:0] src = 8'd3;
  logic [7:0] v = 8'd10;
  wire [7:0] w = src + 8'd1;

  function automatic int twice(int k);
    int y = k * 2;
    k = 100;
    return y;
  endfunction

  initial begin
    #1 $display("start: v=%0d w=%0d", v, w);
    src = 8'd7;
    v = 8'd20;
    #1 $display("after writes: v=%0d w=%0d", v, w);
    #1 $display("later: v=%0d w=%0d", v, w);
    $display("twice(4)=%0d twice(9)=%0d", twice(4), twice(9));
  end
endmodule
