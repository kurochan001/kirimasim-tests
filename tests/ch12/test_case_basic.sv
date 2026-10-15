/*
:name: test_case_basic
:description: Case Statement Tests
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_case_basic.expected
*/
// IEEE 1800-2023 Section 12.5 - Case Statement Tests
module test_case_basic;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int a, result;

        $display("=== IEEE 1800-2023 Case Statement Tests ===");

        // Test 1: Simple case
        $display("Test 1: Simple case");
        a = 2;
        case (a)
            1: result = 10;
            2: result = 20;
            3: result = 30;
            default: result = 0;
        endcase
        if (result == 20) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        // Test 2: Default case
        $display("Test 2: Default");
        a = 99;
        case (a)
            1: result = 10;
            2: result = 20;
            default: result = -1;
        endcase
        if (result == -1) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        // Test 3: Multiple values
        $display("Test 3: Multi values");
        a = 3;
        case (a)
            1, 2: result = 100;
            3, 4: result = 200;
            default: result = 0;
        endcase
        if (result == 200) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        // Test 4: Zero case
        $display("Test 4: Zero case");
        a = 0;
        case (a)
            0: result = 1;
            1: result = 2;
            default: result = -1;
        endcase
        if (result == 1) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        // Test 5: Negative case
        $display("Test 5: Negative");
        a = -1;
        case (a)
            -1: result = 111;
            0: result = 0;
            1: result = 1;
            default: result = -99;
        endcase
        if (result == 111) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        // Test 6: Block in case
        $display("Test 6: Block");
        a = 1;
        case (a)
            1: begin
                result = 5;
                result = result * 2;
            end
            default: result = 0;
        endcase
        if (result == 10) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", result); fail_count++; end

        // Test 7: First match
        $display("Test 7: First match");
        a = 5;
        case (a)
            5: result = 50;
            5: result = 55;
            default: result = 0;
        endcase
        if (result == 50) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        // Test 8: Large value
        $display("Test 8: Large value");
        a = 1000;
        case (a)
            1000: result = 999;
            default: result = 0;
        endcase
        if (result == 999) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
