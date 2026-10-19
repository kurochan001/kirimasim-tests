/*
:name: test_combinational_udp_unlisted_input
:description: A combinational UDP drives x for an input combination that its table does not list (IEEE 1800-2023 Section 29.4)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.4 29.3.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_combinational_udp_unlisted_input.expected
*/
// IEEE 1800-2023 §29.4: a combinational UDP drives the output of the table
// row that matches its inputs, and x for any input combination no row
// specifies (29.3.4). Here the table lists 1 1 and 0 ?, so 1 0 and 1 x
// drive x, while 0 x matches the row 0 ? and drives 0.

primitive one_or_zero (o, a, b);
  output o;
  input a, b;
  table
  // a b : o
    1 1 : 1 ;
    0 ? : 0 ;
  endtable
endprimitive

module test_combinational_udp_unlisted_input;
  reg a, b;
  wire o;

  one_or_zero u (o, a, b);

  initial begin
    a = 1; b = 1;
    #1 $display("a=%b b=%b: o=%b", a, b, o);
    a = 1; b = 0;
    #1 $display("a=%b b=%b: o=%b", a, b, o);
    a = 1; b = 1'bx;
    #1 $display("a=%b b=%b: o=%b", a, b, o);
    a = 0; b = 1'bx;
    #1 $display("a=%b b=%b: o=%b", a, b, o);
  end
endmodule
