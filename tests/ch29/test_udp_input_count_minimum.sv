/*
:name: test_udp_input_count_minimum
:description: A tool accepts a combinational UDP with 10 inputs and a sequential UDP with 9 inputs, the least numbers of inputs every implementation has to allow (IEEE 1800-2023 Section 29.3.2)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3.2 29.4 29.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_input_count_minimum.expected
*/
// IEEE 1800-2023 §29.3.2: an implementation may limit the number of inputs of
// a UDP, but shall allow at least 10 for a combinational UDP and 9 for a
// sequential one. The combinational UDP is a 10-input and; the sequential one
// is a latch whose first input enables it and whose second input is the data,
// with seven more inputs that its table does not look at (29.5).

primitive test_udp_input_count_minimum_and10(y, a, b, c, d, e, f, g, h, i, j);
  output y;
  input a, b, c, d, e, f, g, h, i, j;
  table
    1 1 1 1 1 1 1 1 1 1 : 1;
    0 ? ? ? ? ? ? ? ? ? : 0;
    ? 0 ? ? ? ? ? ? ? ? : 0;
    ? ? 0 ? ? ? ? ? ? ? : 0;
    ? ? ? 0 ? ? ? ? ? ? : 0;
    ? ? ? ? 0 ? ? ? ? ? : 0;
    ? ? ? ? ? 0 ? ? ? ? : 0;
    ? ? ? ? ? ? 0 ? ? ? : 0;
    ? ? ? ? ? ? ? 0 ? ? : 0;
    ? ? ? ? ? ? ? ? 0 ? : 0;
    ? ? ? ? ? ? ? ? ? 0 : 0;
  endtable
endprimitive

primitive test_udp_input_count_minimum_latch9(q, en, d, s1, s2, s3, s4, s5, s6, s7);
  output q;
  reg q;
  input en, d, s1, s2, s3, s4, s5, s6, s7;
  initial q = 0;
  table
    1 0 ? ? ? ? ? ? ? : ? : 0;
    1 1 ? ? ? ? ? ? ? : ? : 1;
    0 ? ? ? ? ? ? ? ? : ? : -;
  endtable
endprimitive

module test_udp_input_count_minimum;
  logic [9:0] in;
  logic en, d;
  logic [6:0] s;
  wire y, q;

  test_udp_input_count_minimum_and10 u1(y, in[9], in[8], in[7], in[6], in[5],
                                        in[4], in[3], in[2], in[1], in[0]);
  test_udp_input_count_minimum_latch9 u2(q, en, d, s[6], s[5], s[4], s[3], s[2], s[1], s[0]);

  initial begin
    in = '1;
    en = 0;
    d = 0;
    s = '0;
    #1 $display("all ones: y=%b", y);
    in[3] = 0;
    #1 $display("one zero: y=%b", y);
    $display("latch closed: q=%b", q);
    d = 1;
    en = 1;
    #1 $display("latch open: q=%b", q);
    en = 0;
    #1 d = 0;
    s = 7'b1010101;
    #1 $display("latch closed again: q=%b", q);
  end
endmodule
