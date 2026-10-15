/*
:name: test_immediate_assume
:description: Immediate Assume Statement Test
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_immediate_assume.expected
*/
// IEEE 1800-2023 §16.14: Immediate Assume Statement Test
// Tests procedural assume (not concurrent assume property)
// Immediate assume failure should stop simulation with exit code 2

module test_immediate_assume;
    int value;
    logic flag;

    initial begin
        $display("=== IEEE 1800-2023 §16.14: Immediate Assume Test ===\n");

        // Test 1: Assume with true condition (passes)
        $display("Test 1: Assume with true condition");
        value = 10;
        assume (value == 10);  // Should pass
        $display("  PASS: assume (value == 10) succeeded\n");

        // Test 2: Assume with expression (passes)
        $display("Test 2: Assume with expression");
        value = 5;
        assume (value > 0 && value < 10);  // Should pass
        $display("  PASS: assume (value > 0 && value < 10) succeeded\n");

        // Test 3: Assume with flag (passes)
        $display("Test 3: Assume with flag");
        flag = 1'b1;
        assume (flag);  // Should pass
        $display("  PASS: assume (flag) succeeded\n");

        // Test 4: Assume with complex condition (passes)
        $display("Test 4: Assume with complex condition");
        value = 15;
        assume (value >= 10 && value <= 20);  // Should pass
        $display("  PASS: assume (value >= 10 && value <= 20) succeeded\n");

        // Test 5: Assume with message (passes)
        $display("Test 5: Assume with message");
        value = 42;
        assume (value == 42) else $display("  Assumption failed: value should be 42");
        $display("  PASS: assume with else message succeeded\n");

        $display("=== All Assume Tests PASSED ===");
        $display("SUCCESS: All immediate assume statements passed");
        $finish;
    end
endmodule
