/*
:name: test_assign_ops
:description: Assignment Operators Tests
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.1 11.4.3 11.4.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_ops.expected
*/
// IEEE 1800-2023 Section 11.4 - Assignment Operators Tests
module test_assign_ops;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int a;

        $display("=== IEEE 1800-2023 Assignment Operators Tests ===");

        // Test 1: Add
        $display("Test 1: Add");
        a = 10;
        a = a + 5;
        if (a == 15) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", a); fail_count++; end

        // Test 2: Sub
        $display("Test 2: Sub");
        a = 20;
        a = a - 8;
        if (a == 12) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", a); fail_count++; end

        // Test 3: Mult
        $display("Test 3: Mult");
        a = 7;
        a = a * 3;
        if (a == 21) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", a); fail_count++; end

        // Test 4: Div
        $display("Test 4: Div");
        a = 100;
        a = a / 4;
        if (a == 25) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", a); fail_count++; end

        // Test 5: Mod
        $display("Test 5: Mod");
        a = 17;
        a = a % 5;
        if (a == 2) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", a); fail_count++; end

        // Test 6: And operation
        $display("Test 6: And op");
        a = 255;
        a = a & 15;
        if (a == 15) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", a); fail_count++; end

        // Test 7: Or operation
        $display("Test 7: Or op");
        a = 240;
        a = a | 15;
        if (a == 255) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", a); fail_count++; end

        // Test 8: Xor operation
        $display("Test 8: Xor op");
        a = 255;
        a = a ^ 15;
        if (a == 240) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", a); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
