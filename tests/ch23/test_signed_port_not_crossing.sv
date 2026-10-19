/*
:name: test_signed_port_not_crossing
:description: Signedness does not pass through a port: each side reads the value with its own declaration (IEEE 1800-2023 Section 23.3.3.8)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.8 23.3.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_signed_port_not_crossing.expected
*/
// IEEE 1800-2023 §23.3.3.8: the signed attribute does not cross a port. The
// bits pass through, and each side interprets them with its own declaration,
// so 4'b1101 is -3 where it is declared signed and 13 where it is not. An
// expression connected to a port is evaluated like the right-hand side of an
// assignment to the port.

module signed_port_src(output logic signed [3:0] o);
  assign o = -4'sd3;
endmodule

module signed_port_dst_signed(input logic signed [3:0] i, output int w);
  assign w = i;
endmodule

module signed_port_dst_unsigned(input logic [3:0] i, output int w);
  assign w = i;
endmodule

module test_signed_port_not_crossing;
  wire [3:0] n_unsigned;
  wire signed [3:0] n_signed;
  int w1, w2, w3, w4;

  signed_port_src s1(.o(n_unsigned));
  signed_port_src s2(.o(n_signed));
  signed_port_dst_signed   d1(.i(n_unsigned), .w(w1));
  signed_port_dst_unsigned d2(.i(n_signed), .w(w2));
  signed_port_dst_signed   d3(.i(4'sd2 - 4'sd5), .w(w3));
  signed_port_dst_unsigned d4(.i(4'sd2 - 4'sd5), .w(w4));

  initial begin
    #1;
    $display("unsigned net: %0d, signed net: %0d", n_unsigned, n_signed);
    $display("into signed port: %0d, into unsigned port: %0d", w1, w2);
    $display("expression into signed port: %0d, into unsigned port: %0d", w3, w4);
  end
endmodule
