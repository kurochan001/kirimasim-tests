/*
:name: test_directive_nested
:description: Compiler directives edge cases
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1 22.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_directive_nested.expected
*/
// IEEE 1800-2023 §22: Compiler directives edge cases
// Tests nested and complex directive interactions

`define OUTER_WIDTH 8
`define INNER_WIDTH (`OUTER_WIDTH / 2)

`define MACRO_WITH_ARGS(x, y) ((x) + (y))
`define NESTED_MACRO(a) `MACRO_WITH_ARGS(a, a)

`ifndef GUARD_TEST_DIRECTIVE
`define GUARD_TEST_DIRECTIVE

module test_directive_nested;
  // Test 1: Nested macro expansion
  localparam int OUTER = `OUTER_WIDTH;
  localparam int INNER = `INNER_WIDTH;
  
  // Test 2: Macro with arguments
  localparam int SUM = `MACRO_WITH_ARGS(3, 5);
  
  // Test 3: Nested macro invocation
  localparam int DOUBLED = `NESTED_MACRO(7);
  
  int test_count = 0;

  initial begin
    // Verify nested macro expansion
    test_count++;
    assert(OUTER == 8) else $error("OUTER_WIDTH should be 8");
    $display("Test %0d: Outer macro = %0d", test_count, OUTER);

    test_count++;
    assert(INNER == 4) else $error("INNER_WIDTH should be OUTER/2 = 4");
    $display("Test %0d: Nested macro = %0d", test_count, INNER);

    // Verify macro with arguments
    test_count++;
    assert(SUM == 8) else $error("MACRO_WITH_ARGS(3,5) should be 8");
    $display("Test %0d: Macro args = %0d", test_count, SUM);

    // Verify nested macro invocation
    test_count++;
    assert(DOUBLED == 14) else $error("NESTED_MACRO(7) should be 14");
    $display("Test %0d: Nested invocation = %0d", test_count, DOUBLED);

    // Test conditional compilation
    test_count++;
`ifdef GUARD_TEST_DIRECTIVE
    $display("Test %0d: Guard defined correctly", test_count);
`else
    $error("Guard should be defined");
`endif

    // Test undefined check
    test_count++;
`ifndef UNDEFINED_MACRO
    $display("Test %0d: Undefined macro check OK", test_count);
`else
    $error("UNDEFINED_MACRO should not be defined");
`endif

    $display("All %0d directive tests passed", test_count);
    $display("TEST PASSED");
    $finish;
  end
endmodule

`endif // GUARD_TEST_DIRECTIVE
