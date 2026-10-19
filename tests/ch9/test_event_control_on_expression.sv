/*
:name: test_event_control_on_expression
:description: An event control on an operator expression waits for a change of the expression's value, not for any change of its operands (IEEE 1800-2023 Section 9.4.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_control_on_expression.expected
*/
// IEEE 1800-2023 §9.4.2: an event control @(expression) resumes when the
// value of the expression changes. When a goes 0 -> 1 -> 5 -> 6 -> 10 -> 12
// -> 3, a & 4'b0011 changes only at the steps to 1, 6, 12 and 3, and a > 5
// only at the steps to 6 and to 3, while @(a) resumes at every step. The
// counters are cleared at time 1, so they count only these steps.

module test_event_control_on_expression;
  logic [3:0] a = 0;
  int n_mask = 0, n_cmp = 0, n_any = 0;

  always @(a & 4'b0011) n_mask++;
  always @(a > 4'd5) n_cmp++;
  always @(a) n_any++;

  initial begin
    #1;
    n_mask = 0;
    n_cmp = 0;
    n_any = 0;
    #1 a = 4'd1;
    #1 a = 4'd5;
    #1 a = 4'd6;
    #1 a = 4'd10;
    #1 a = 4'd12;
    #1 a = 4'd3;
    #1 $display("@(a & 4'b0011): %0d, @(a > 5): %0d, @(a): %0d", n_mask, n_cmp, n_any);
  end
endmodule
