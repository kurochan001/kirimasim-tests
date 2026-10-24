/*
:name: test_illegal_generate_region_without_endgenerate
:description: A generate keyword has to be matched by an endgenerate keyword, so a module that ends while its generate region is still open is illegal, while a region closed by endgenerate before it is legal (IEEE 1800-2023 Section 27.3)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second generate region of the module has no endgenerate before endmodule
:expected_stderr_regex: test_illegal_generate_region_without_endgenerate\.sv:31:
*/
// IEEE 1800-2023 §27.3: if the generate keyword is used, it shall be matched by
// an endgenerate keyword. The first region of the module, with the block g1,
// is closed by endgenerate, which is legal. The second region, with the block
// g2, is still open when endmodule comes, which is where the missing keyword
// is found.

module test_illegal_generate_region_without_endgenerate;
  generate
    if (1) begin : g1
      int b = 1;
    end
  endgenerate
  initial $display("%0d", g1.b);
  generate
    if (1) begin : g2
      int c = 2;
    end
endmodule   // illegal: the generate region above has no endgenerate
