/*
:name: test_udp_ansi_header
:description: A UDP declared with an ANSI-style header takes its ports from the header, and a sequential one also the reg of its output and its initial value (IEEE 1800-2023 Section 29.3.1)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3.1 29.3.2 29.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_ansi_header.expected
*/
// IEEE 1800-2023 §29.3.1, §29.3.2: in the second form of a UDP header the
// parentheses hold the port declarations, the output first, and no port
// declarations follow. A combinational UDP declares output y there; a
// sequential one declares output reg q and may give it an initial value,
// which is the state at the start of the simulation (29.7). So q is 1 before
// the first rising clock, which loads d = 0; the next one loads d = 1.

primitive udp_and_ansi (output y, input a, b);
  table
  // a b : y
     1 1 : 1;
     0 ? : 0;
     ? 0 : 0;
  endtable
endprimitive

primitive udp_dff_ansi (output reg q = 1'b1, input clk, d);
  table
  // clk d : q : q+
     r   0 : ? : 0;
     r   1 : ? : 1;
     n   ? : ? : -;
     ?   * : ? : -;
  endtable
endprimitive

module test_udp_ansi_header;
  reg clk, d, a, b;
  wire y, q;

  udp_and_ansi g (y, a, b);
  udp_dff_ansi u (q, clk, d);

  initial begin
    clk = 0;
    d = 0;
    a = 0;
    b = 1;
    #1 $display("t=%0d: y=%b q=%b", $time, y, q);
    a = 1;
    clk = 1;
    #1 $display("t=%0d: y=%b q=%b", $time, y, q);
    clk = 0;
    d = 1;
    #1 clk = 1;
    #1 $display("t=%0d: y=%b q=%b", $time, y, q);
  end
endmodule
