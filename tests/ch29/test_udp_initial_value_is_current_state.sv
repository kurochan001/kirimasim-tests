/*
:name: test_udp_initial_value_is_current_state
:description: The initial statement of a sequential UDP sets the current state that its table matches, so two instances with different initial values take different next states (IEEE 1800-2023 Section 29.7)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.7 29.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_initial_value_is_current_state.expected
*/
// IEEE 1800-2023 §29.7: the initial statement gives the output of a sequential
// UDP the value it starts with, which is the current state that its table
// entries match (29.6). The table of both primitives toggles on a rising clock
// through its current-state field. u0 starts at 0 and u1 at 1, so each rising
// clock exchanges their values.

primitive udp_toggle0 (q, clk);
  output q;
  reg q;
  input clk;
  initial q = 0;
  table
  // clk : q : q+
    r   : 0 : 1;
    r   : 1 : 0;
    f   : ? : -;
    (x0) : ? : -;
  endtable
endprimitive

primitive udp_toggle1 (q, clk);
  output q;
  reg q;
  input clk;
  initial q = 1;
  table
  // clk : q : q+
    r   : 0 : 1;
    r   : 1 : 0;
    f   : ? : -;
    (x0) : ? : -;
  endtable
endprimitive

module test_udp_initial_value_is_current_state;
  reg clk;
  wire q0, q1;

  udp_toggle0 u0 (q0, clk);
  udp_toggle1 u1 (q1, clk);

  initial begin
    clk = 0;
    #1 $display("clk=%b: q0=%b q1=%b", clk, q0, q1);
    clk = 1;
    #1 $display("clk=%b: q0=%b q1=%b", clk, q0, q1);
    clk = 0;
    #1 $display("clk=%b: q0=%b q1=%b", clk, q0, q1);
    clk = 1;
    #1 $display("clk=%b: q0=%b q1=%b", clk, q0, q1);
  end
endmodule
