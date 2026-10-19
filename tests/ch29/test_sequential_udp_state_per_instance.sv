/*
:name: test_sequential_udp_state_per_instance
:description: Each instance of a sequential UDP keeps its own state, also inside two instances of one module (IEEE 1800-2023 Section 29.6)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.6 29.3.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequential_udp_state_per_instance.expected
*/
// IEEE 1800-2023 §29.6: in an edge-sensitive sequential UDP, the output is a
// state that the table updates on input transitions; a "-" in the next state
// column keeps the current state (29.3.6). The state belongs to the
// instance: two instances of the same module, each containing one instance
// of the UDP, store different values and keep them on a clock edge that
// leaves both unchanged.

primitive rising_dff (q, clk, d);
  output q;
  reg q;
  input clk, d;
  table
  // clk d : q : q+
    r   0 : ? : 0 ;
    r   1 : ? : 1 ;
    f   ? : ? : - ;
    ?   * : ? : - ;
  endtable
endprimitive

module dff_cell (input logic clk, input logic d, output logic q);
  rising_dff u (q, clk, d);
endmodule

module test_sequential_udp_state_per_instance;
  logic clk = 0;
  logic da, db;
  wire qa, qb;
  dff_cell ca (clk, da, qa);
  dff_cell cb (clk, db, qb);

  initial begin
    da = 1;
    db = 0;
    #1 clk = 1;
    #1 $display("after the first rising edge: qa=%b qb=%b", qa, qb);
    clk = 0;
    #1 clk = 1;
    #1 $display("after the second rising edge: qa=%b qb=%b", qa, qb);
    da = 0;
    db = 1;
    #1 $display("after d changes without an edge: qa=%b qb=%b", qa, qb);
    clk = 0;
    #1 clk = 1;
    #1 $display("after the third rising edge: qa=%b qb=%b", qa, qb);
  end
endmodule
