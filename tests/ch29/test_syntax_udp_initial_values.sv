/*
:name: test_syntax_udp_initial_values
:description: the initial statement of a sequential UDP accepts 1'b0, 1'b1, 1'bx, 1'bX, 1'B0, 1'B1, 1'Bx, 1'BX, 1 and 0, and the value is the state at the start of the simulation (IEEE 1800-2023 Section 29.7)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.7 29.3.3 A.5.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_syntax_udp_initial_values.expected
*/
// IEEE 1800-2023 A.5.3, §29.3.3, §29.7: the initial statement of a
// sequential UDP assigns to the output one of 1'b0, 1'b1, 1'bx, 1'bX, 1'B0,
// 1'B1, 1'Bx, 1'BX, 1 or 0, and that value is the output and the current
// state when the simulation starts. Ten toggle UDPs differ only in this
// value. Their outputs are printed before any edge of their input, and again
// after one rising edge: a state of 0 becomes 1, a state of 1 becomes 0, and
// a state of x, which no row covers, stays x (29.6).

`define TOGGLE_UDP(name, value) \
  primitive name (q, t); \
    output q; \
    reg q; \
    input t; \
    initial q = value; \
    table \
      r    : 0 : 1; \
      r    : 1 : 0; \
      f    : ? : -; \
      (x0) : ? : -; \
    endtable \
  endprimitive

`TOGGLE_UDP(u_b0, 1'b0)
`TOGGLE_UDP(u_b1, 1'b1)
`TOGGLE_UDP(u_bx, 1'bx)
`TOGGLE_UDP(u_bX, 1'bX)
`TOGGLE_UDP(u_B0, 1'B0)
`TOGGLE_UDP(u_B1, 1'B1)
`TOGGLE_UDP(u_Bx, 1'Bx)
`TOGGLE_UDP(u_BX, 1'BX)
`TOGGLE_UDP(u_1, 1)
`TOGGLE_UDP(u_0, 0)

module test_syntax_udp_initial_values;
  reg t;
  wire [9:0] q;

  u_b0 g0 (q[9], t);
  u_b1 g1 (q[8], t);
  u_bx g2 (q[7], t);
  u_bX g3 (q[6], t);
  u_B0 g4 (q[5], t);
  u_B1 g5 (q[4], t);
  u_Bx g6 (q[3], t);
  u_BX g7 (q[2], t);
  u_1  g8 (q[1], t);
  u_0  g9 (q[0], t);

  initial begin
    t = 0;
    #1 $display("initial: %b", q);
    t = 1;
    #1 $display("after r: %b", q);
  end
endmodule
