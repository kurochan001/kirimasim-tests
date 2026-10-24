/*
:name: test_illegal_generate_block_specify
:description: A generate block cannot contain a specify block, while the module itself can have one and the generate block can hold a nested generate construct (IEEE 1800-2023 Section 27.2)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the generate block of gsp_cell contains a specify block
:expected_stderr_regex: test_illegal_generate_block_specify\.sv:29:
*/
// IEEE 1800-2023 §27.2: a generate block may not contain port declarations,
// specify blocks or specparam declarations; other module items, including
// other generate constructs, are allowed. gsp_cell has a specify block of its
// own, which is legal. Its generate block holds a nested if-generate
// construct, also legal, and a specify block.

module gsp_cell(input wire a, output wire y);
  buf g1 (y, a);
  specify
    (a => y) = 2;
  endspecify
  if (1) begin : g
    if (1) begin : inner
      wire t;
    end
    specify   // illegal: a specify block in a generate block
      (a => y) = 3;
    endspecify
  end
endmodule

module test_illegal_generate_block_specify;
  logic a = 1'b1;
  wire y;
  gsp_cell u (.a(a), .y(y));
  initial #5 $display("%b", y);
endmodule
