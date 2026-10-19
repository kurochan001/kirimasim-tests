/*
:name: test_udp_z_input_as_x
:description: A z on an input of a user-defined primitive is treated as x when the table is matched (IEEE 1800-2023 Section 29.3.5)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3.5 29.3.6 29.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_z_input_as_x.expected
*/
// IEEE 1800-2023 §29.3.5: a z value reaching an input of a UDP is treated as x.
// So it matches table entries written with x or with ? (29.3.6), and when no
// entry matches the output is x (29.4).

primitive udp_zx(y, a, b);
  output y;
  input a, b;
  table
  // a b : y
     0 ? : 0;
     1 0 : 1;
     1 1 : 0;
     x 1 : 1;
  endtable
endprimitive

module test_udp_z_input_as_x;
  reg a, b;
  wire y;

  udp_zx g(y, a, b);

  initial begin
    a = 1'bz; b = 1'b1;
    #1 $display("a=z b=1: y=%b", y);
    a = 1'bx; b = 1'b1;
    #1 $display("a=x b=1: y=%b", y);
    a = 1'bz; b = 1'b0;
    #1 $display("a=z b=0: y=%b", y);
    a = 1'b0; b = 1'bz;
    #1 $display("a=0 b=z: y=%b", y);
  end
endmodule
