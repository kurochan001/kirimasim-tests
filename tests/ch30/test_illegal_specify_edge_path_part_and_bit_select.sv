/*
:name: test_illegal_specify_edge_path_part_and_bit_select
:description: Edge-sensitive state-dependent paths with different conditions still have to reference the destination port in the same way; a part-select in one and a bit-select in the other is an error (IEEE 1800-2023 Section 30.4.4.3)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.4.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the edge-sensitive paths from clk to q reference q by the part-select q[3:0] under rst and by the bit-select q[0] under !rst
:expected_stderr_regex: test_illegal_specify_edge_path_part_and_bit_select\.sv:(30|31):
*/
// IEEE 1800-2023 §30.4.4.3: delays can be assigned to the same edge-sensitive
// path several times only if the port is referenced in the same way in all
// the path declarations, as the entire port, a bit-select or a part-select.
// The paths to p use the entire port under both conditions, which is legal.
// The paths to q differ in their conditions but use the part-select q[3:0]
// in one and the bit-select q[0] in the other. A tool can report the
// mismatch on either of the two lines.
// Icarus Verilog 13.0 and the 5.052 release of Verilator accept the design.

module seb_cell(input wire clk, input wire rst, input wire [3:0] d,
                output wire [3:0] q, output wire [3:0] p);
  assign q = d;
  assign p = d;
  specify
    if (rst) (posedge clk *> (p : d)) = (2, 3);
    if (!rst) (posedge clk *> (p : d)) = (4, 5);
    if (rst) (posedge clk *> (q[3:0] : d)) = (2, 3);
    if (!rst) (posedge clk *> (q[0] : d)) = (4, 5);   // illegal: q[0] while the other uses q[3:0]
  endspecify
endmodule

module test_illegal_specify_edge_path_part_and_bit_select;
  logic clk = 1'b0, rst = 1'b0;
  logic [3:0] d = 4'h5;
  wire [3:0] q, p;
  seb_cell u (.clk(clk), .rst(rst), .d(d), .q(q), .p(p));
  initial #10 $display("%h %h", q, p);
endmodule
