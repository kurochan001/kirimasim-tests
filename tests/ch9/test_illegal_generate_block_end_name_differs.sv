/*
:name: test_illegal_generate_block_end_name_differs
:description: a name after the end of a generate block has to be the name of the block (IEEE 1800-2023 Section 9.3.4)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.3.4 27.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the generate block named gen_a ends with end : gen_b
:expected_stderr_regex: test_illegal_generate_block_end_name_differs\.sv:30:
*/
// IEEE 1800-2023 §9.3.4: a matching block name may follow end at the end of a
// generate block (27.3); it is not required, but it shall be an error if it
// differs from the name at the beginning of the block. g_ok ends with its own
// name and g_none ends without one; gen_a ends with another name.

module test_illegal_generate_block_end_name_differs;
  if (1) begin : g_ok
    wire w = 1'b1;
  end : g_ok

  if (1) begin : g_none
    wire w = 1'b0;
  end

  if (1) begin : gen_a
    wire w = 1'b1;
  end : gen_b   // illegal: another name than gen_a

  initial #1 $display("%b %b", g_ok.w, g_none.w);
endmodule
