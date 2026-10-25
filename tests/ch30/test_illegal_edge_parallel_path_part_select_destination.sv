/*
:name: test_illegal_edge_parallel_path_part_select_destination
:description: The destination of a parallel edge-sensitive path cannot be a part-select, while a full edge-sensitive path can have a list of a part-select and a scalar port as its destinations (IEEE 1800-2023 Section 30.4.3)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the parallel edge-sensitive path from c2 has the part-select q[1:0] as its destination
:expected_stderr_regex: test_illegal_edge_parallel_path_part_select_destination\.sv:29:
*/
// IEEE 1800-2023 §30.4.3: a parallel edge-sensitive path (=>) has a scalar port
// or a bit-select as its destination, and a full one (*>) a list of ports,
// bit-selects and part-selects. The full path to q[3:2] and s is legal; the
// parallel path from the two-bit c2 to the two-bit q[1:0] is not.
// Icarus Verilog 13.0 applies a path to a part-select to the whole vector and
// reports a width mismatch (2/4) on the illegal line, which is not the
// diagnosis of the rule and does not count; the 5.052 release of Verilator
// accepts the design.

module epp_cell(input wire clk, input wire [1:0] c2, input wire [3:0] d,
                output wire [3:0] q, output wire s);
  assign q = d;
  assign s = d[0];
  specify
    (posedge clk *> (q[3:2], s : d)) = (2, 3);
    (posedge c2 => (q[1:0] : d[1:0])) = (4, 5);   // illegal: a part-select with =>
  endspecify
endmodule

module test_illegal_edge_parallel_path_part_select_destination;
  logic clk = 1'b0;
  logic [1:0] c2 = 2'b00;
  logic [3:0] d = 4'h6;
  wire [3:0] q;
  wire s;
  epp_cell u (.clk(clk), .c2(c2), .d(d), .q(q), .s(s));
  initial #10 $display("%h %b", q, s);
endmodule
