/*
:name: test_assert_simple
:description: Simple Assertion Tests
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assert_simple.expected
*/
// IEEE 1800-2023 Section 16 - Simple Assertion Tests
module test_assert_simple;
    int pass_count = 0;
    int fail_count = 0;
    logic clk = 0;

    always #5 clk = ~clk;

    initial begin
        $display("=== IEEE 1800-2023 Simple Assertion Tests ===");

        // Test 1-8: Simple checks
        $display("Test 1: True assert");
        assert(1 == 1) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        $display("Test 2: Math assert");
        assert(2 + 2 == 4) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        $display("Test 3: Compare");
        assert(5 > 3) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        $display("Test 4: Equal");
        assert(10 == 10) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        $display("Test 5: Not equal");
        assert(5 != 6) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        $display("Test 6: Less than");
        assert(3 < 10) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        $display("Test 7: GE");
        assert(5 >= 5) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        $display("Test 8: LE");
        assert(4 <= 4) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
