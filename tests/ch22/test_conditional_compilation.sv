/*
:name: test_conditional_compilation
:description: Compiler Directives Test
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_conditional_compilation.expected
*/
// IEEE 1800-2023 §22 Compiler Directives Test
// Tests: `ifdef, `ifndef, `elsif, `else, `endif

`define FEATURE_A
// `define FEATURE_B is not defined

module test_conditional_compilation;
  logic [7:0] result;

  initial begin
    result = 0;

    // Test ifdef
    `ifdef FEATURE_A
      result = result + 8'h10;
    `endif

    // Test ifndef
    `ifndef FEATURE_B
      result = result + 8'h01;
    `endif

    assert(result == 8'h11) else $fatal(1, "ifdef/ifndef failed: expected 0x11, got 0x%02h", result);

    // Test elsif/else
    `ifdef FEATURE_B
      result = 8'hFF;  // Should not execute
    `elsif FEATURE_A
      result = result + 8'h20;  // Should execute
    `else
      result = 8'h00;  // Should not execute
    `endif

    assert(result == 8'h31) else $fatal(1, "elsif failed: expected 0x31, got 0x%02h", result);

    // Test nested conditionals
    `ifdef FEATURE_A
      `ifndef FEATURE_B
        result = result + 8'h08;
      `endif
    `endif

    assert(result == 8'h39) else $fatal(1, "Nested conditionals failed: expected 0x39, got 0x%02h", result);

    $display("PASS: Conditional compilation directives test completed");
    $finish;
  end
endmodule
