/*
:name: test_illegal_generate_block_port_declaration
:description: A generate block cannot contain a port declaration, while it can contain other module items such as a net declaration and a continuous assignment (IEEE 1800-2023 Section 27.2)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the generate block of gpd_cell declares the port b
:expected_stderr_regex: test_illegal_generate_block_port_declaration\.sv:30:
*/
// IEEE 1800-2023 §27.2: a generate block is a collection of module items, and
// it may not contain port declarations, specify blocks or specparam
// declarations; all other module items, including other generate constructs,
// are allowed. gpd_cell has a non-ANSI port list (a, b, y): a and y are
// declared in the module, which is legal, and the generate block declares a
// net and an assignment, also legal, and the port b.
// Icarus Verilog 13.0 does not report the port declaration in the generate
// block; it reports that the port b is not declared in the module, on the
// module header, which does not count.

module gpd_cell(a, b, y);
  input a;
  output y;
  if (1) begin : g
    wire t;
    assign t = a;
    input b;   // illegal: a port declaration in a generate block
  end
  assign y = g.t;
endmodule

module test_illegal_generate_block_port_declaration;
  logic a = 1'b1, b = 1'b0;
  wire y;
  gpd_cell u (a, b, y);
  initial #1 $display("%b", y);
endmodule
