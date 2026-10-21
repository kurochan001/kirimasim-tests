/*
:name: test_udp_current_state_x_entry
:description: In a sequential UDP table, an x in the current-state field matches an unknown output at the edge, and a 0 or 1 there matches only that known state (IEEE 1800-2023 Section 29.6)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.6 29.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_current_state_x_entry.expected
*/
// IEEE 1800-2023 §29.6, §29.7: the current-state field of a table entry is
// matched like the input fields, so x matches an unknown output and 0 and 1
// match those known values. The output starts at x (29.7). The first rising
// clock therefore takes the entry r : x : 0, the second takes r : 0 : 1, and
// the third, from 1, keeps 1 through r : 1 : 1.

primitive udp_x_state (q, clk);
  output q;
  reg q;
  input clk;
  table
  // clk : q : q+
    r    : x : 0;
    r    : 0 : 1;
    r    : 1 : 1;
    f    : ? : -;
    (x0) : ? : -;
  endtable
endprimitive

module test_udp_current_state_x_entry;
  reg clk;
  wire q;

  udp_x_state u (q, clk);

  initial begin
    clk = 0;
    #1 $display("clk=%b: q=%b", clk, q);
    #1 clk = 1;
    #1 $display("clk=%b: q=%b", clk, q);
    #1 clk = 0;
    #1 clk = 1;
    #1 $display("clk=%b: q=%b", clk, q);
    #1 clk = 0;
    #1 clk = 1;
    #1 $display("clk=%b: q=%b", clk, q);
  end
endmodule
