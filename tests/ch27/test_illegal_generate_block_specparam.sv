/*
:name: test_illegal_generate_block_specparam
:description: A generate block cannot contain a specparam declaration, while it can contain a localparam and the module itself can declare a specparam (IEEE 1800-2023 Section 27.2)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the generate block of the module declares the specparam tg
:expected_stderr_regex: test_illegal_generate_block_specparam\.sv:23:
*/
// IEEE 1800-2023 §27.2: a generate block may not contain specparam
// declarations. The module declares the specparam tm as a module item and the
// generate block declares the localparam lp, both legal; the generate block
// also declares the specparam tg.

module test_illegal_generate_block_specparam;
  specparam tm = 4;
  if (1) begin : g
    localparam int lp = 5;
    specparam tg = 6;   // illegal: a specparam in a generate block
  end
  initial $display("%0d %0d", tm, g.lp);
endmodule
