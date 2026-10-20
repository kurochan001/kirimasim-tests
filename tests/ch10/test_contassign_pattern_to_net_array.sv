/*
:name: test_contassign_pattern_to_net_array
:description: A continuous assignment of an array assignment pattern to an unpacked net array drives the elements from the left bound and follows its operands (IEEE 1800-2023 Section 10.9.1)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.9.1 10.3.2 7.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_contassign_pattern_to_net_array.expected
*/
// IEEE 1800-2023 §10.9.1: the items of an array assignment pattern go to the
// elements of the array from its left bound to its right bound (7.4), each
// converted to the element type as in an assignment. This holds for the
// continuous assignment of a pattern to an unpacked net array (10.3.2): for
// d[1:0] the first item drives d[1], for a[1:2] it drives a[1], a 5-bit item
// keeps its low 4 bits, and the nets follow when an operand changes.

module test_contassign_pattern_to_net_array;
  logic [3:0] p = 4'ha, q = 4'hb;
  logic [4:0] w = 5'b10110;
  wire [3:0] d[1:0];
  wire [3:0] a[1:2];
  wire [3:0] e[1:0];

  assign d = '{p, q};
  assign a = '{4'hf, w};
  assign e = '{4'h1, 4'h2};

  initial begin
    #1 $display("d[1]=%h d[0]=%h a[1]=%h a[2]=%h e[1]=%h e[0]=%h", d[1], d[0], a[1], a[2], e[1],
                e[0]);
    p = 4'h3;
    #1 $display("after p = 3: d[1]=%h d[0]=%h", d[1], d[0]);
  end
endmodule
