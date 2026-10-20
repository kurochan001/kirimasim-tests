/*
:name: test_udp_b_symbol_excludes_x
:description: In a UDP table, b matches only 0 and 1 while ? also matches x, so an x input that only a b entry would cover gives x unless an entry lists x (IEEE 1800-2023 Section 29.3.6)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3.6 29.4 29.3.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_b_symbol_excludes_x.expected
*/
// IEEE 1800-2023 §29.3.6, Table 29-1: in an input field, b is 0 or 1, and ? is
// 0, 1 or x. In udp_b, a = x with s = 0 matches no entry, so the output is x
// (29.4); with s = 1 the ? entry matches and gives 0. udp_bx has the same
// entries and also one with x for a, which gives 0 for a = x and s = 0. With
// s = x neither UDP has an entry, and both give x.

primitive udp_b (y, a, s);
  output y;
  input a, s;
  table
  // a s : y
     b 0 : 1;
     ? 1 : 0;
  endtable
endprimitive

primitive udp_bx (y, a, s);
  output y;
  input a, s;
  table
  // a s : y
     b 0 : 1;
     x 0 : 0;
     ? 1 : 0;
  endtable
endprimitive

module test_udp_b_symbol_excludes_x;
  reg a, s;
  wire y_b, y_bx;

  udp_b g1 (y_b, a, s);
  udp_bx g2 (y_bx, a, s);

  task apply(input logic va, input logic vs);
    a = va;
    s = vs;
    #1 $display("a=%b s=%b: udp_b=%b udp_bx=%b", a, s, y_b, y_bx);
  endtask

  initial begin
    apply(1'b0, 1'b0);
    apply(1'b1, 1'b0);
    apply(1'bx, 1'b0);
    apply(1'bx, 1'b1);
    apply(1'b1, 1'b1);
    apply(1'b0, 1'bx);
  end
endmodule
