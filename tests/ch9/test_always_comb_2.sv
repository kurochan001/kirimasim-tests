/*
:name: test_always_comb_2
:description: Always_comb Tests
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_2.expected
*/
// IEEE 1800-2023 Section 9.2.2 - Always_comb Tests
module test_always_comb;
    int pass_count = 0;
    int fail_count = 0;
    
    logic [7:0] a, b;
    logic [7:0] sum, diff, prod;

    always_comb begin
        sum = a + b;
        diff = a - b;
        prod = a * b;
    end

    initial begin
        $display("=== IEEE 1800-2023 Always_comb Tests ===");

        // Test 1: Initial sum
        $display("Test 1: Sum");
        a = 10;
        b = 5;
        #1;
        if (sum == 15) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", sum); fail_count++; end

        // Test 2: Difference
        $display("Test 2: Diff");
        if (diff == 5) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", diff); fail_count++; end

        // Test 3: Product
        $display("Test 3: Prod");
        if (prod == 50) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", prod); fail_count++; end

        // Test 4: Change a
        $display("Test 4: Change a");
        a = 20;
        #1;
        if (sum == 25) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", sum); fail_count++; end

        // Test 5: Change b
        $display("Test 5: Change b");
        b = 10;
        #1;
        if (sum == 30) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", sum); fail_count++; end

        // Test 6: Equal values
        $display("Test 6: Equal");
        a = 8;
        b = 8;
        #1;
        if (diff == 0) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", diff); fail_count++; end

        // Test 7: Zero values
        $display("Test 7: Zero");
        a = 0;
        b = 0;
        #1;
        if (sum == 0 && diff == 0 && prod == 0) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        // Test 8: Final
        $display("Test 8: Final");
        a = 12;
        b = 3;
        #1;
        if (prod == 36) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", prod); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
