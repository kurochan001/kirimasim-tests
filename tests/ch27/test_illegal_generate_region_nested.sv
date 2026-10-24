/*
:name: test_illegal_generate_region_nested
:description: Generate regions do not nest, so a generate keyword inside a generate region is illegal, while a module can have several generate regions one after the other and generate constructs outside of any region (IEEE 1800-2023 Section 27.3)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a generate region begins inside the generate block g2 of a generate region
:expected_stderr_regex: test_illegal_generate_region_nested\.sv:31:
*/
// IEEE 1800-2023 §27.3: the keywords generate and endgenerate define a
// generate region; its use is optional, regions do not nest, and they may only
// occur directly within a module. The module has the generate construct g0
// outside of any region and a region with g1, which are legal; a second
// region contains the block g2, inside which another region begins.

module test_illegal_generate_region_nested;
  if (1) begin : g0
    int a = 0;
  end
  generate
    if (1) begin : g1
      int b = 1;
    end
  endgenerate
  generate
    if (1) begin : g2
      generate   // illegal: a generate region inside a generate region
        if (1) begin : g3
          int c = 2;
        end
      endgenerate
    end
  endgenerate
  initial $display("%0d %0d", g0.a, g1.b);
endmodule
