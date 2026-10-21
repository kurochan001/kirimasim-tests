/*
:name: test_udp_input_symbol_x_literal
:description: In a combinational UDP table the input symbol x matches only an unknown input, while ? matches any value, so an x entry and a ? entry cover different input combinations (IEEE 1800-2023 Section 29.3.6)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3.6 29.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_input_symbol_x_literal.expected
*/
// IEEE 1800-2023 §29.3.6, Table 29-1: in an input field, x matches x (and z,
// which is treated as x, 29.3.5), not 0 or 1, and ? matches 0, 1 and x. So
// x 0 and 0 x give 1 here, 0 0 gives 0, and 1 0, 0 1 and 1 1 match no entry
// and give x (29.4).

primitive udp_x_input (y, a, b);
  output y;
  input a, b;
  table
  // a b : y
    x ? : 1;
    ? x : 1;
    0 0 : 0;
  endtable
endprimitive

module test_udp_input_symbol_x_literal;
  reg a, b;
  wire y;

  udp_x_input u (y, a, b);

  task apply(input logic va, input logic vb);
    a = va;
    b = vb;
    #1 $display("a=%b b=%b: y=%b", a, b, y);
  endtask

  initial begin
    apply(1'b0, 1'b0);
    apply(1'b1, 1'b0);
    apply(1'bx, 1'b0);
    apply(1'b0, 1'bx);
    apply(1'b1, 1'b1);
    apply(1'b0, 1'b1);
  end
endmodule
