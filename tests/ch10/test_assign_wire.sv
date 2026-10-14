/*
:name: test_assign_wire
:description: Continuous Assignment Tests
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_wire.expected
*/
// IEEE 1800-2023 Section 10.3 - Continuous Assignment Tests
module test_assign_wire;
    int pass_count = 0;
    int fail_count = 0;

    logic [7:0] a, b;
    wire [7:0] sum, diff;

    assign sum = a + b;
    assign diff = a - b;

    initial begin
        $display("=== IEEE 1800-2023 Continuous Assignment Tests ===");

        // Test 1-8
        $display("Test 1: Init sum");
        a = 10; b = 5;
        #1;
        if (sum == 15) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", sum); fail_count++; end

        $display("Test 2: Init diff");
        if (diff == 5) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", diff); fail_count++; end

        $display("Test 3: Change a");
        a = 20;
        #1;
        if (sum == 25) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", sum); fail_count++; end

        $display("Test 4: Change b");
        b = 10;
        #1;
        if (sum == 30) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", sum); fail_count++; end

        $display("Test 5: Zero");
        a = 0; b = 0;
        #1;
        if (sum == 0) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        $display("Test 6: Equal");
        a = 8; b = 8;
        #1;
        if (diff == 0) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", diff); fail_count++; end

        $display("Test 7: Max");
        a = 255; b = 0;
        #1;
        if (sum == 255) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", sum); fail_count++; end

        $display("Test 8: Both");
        a = 100; b = 50;
        #1;
        if (sum == 150 && diff == 50) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
