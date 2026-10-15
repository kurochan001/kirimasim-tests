/*
:name: test_unique_case
:description: Unique/Priority Case Tests
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_case.expected
*/
// IEEE 1800-2023 Section 12.5.3 - Unique/Priority Case Tests
module test_unique_case;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int a, result;

        $display("=== IEEE 1800-2023 Unique/Priority Case Tests ===");

        // Test 1: Unique case match
        $display("Test 1: Unique match");
        a = 2;
        unique case (a)
            1: result = 10;
            2: result = 20;
            3: result = 30;
        endcase
        if (result == 20) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        // Test 2: Priority case
        $display("Test 2: Priority");
        a = 1;
        priority case (a)
            1: result = 100;
            2: result = 200;
        endcase
        if (result == 100) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        // Test 3: Unique0 case
        $display("Test 3: Unique0");
        a = 3;
        unique0 case (a)
            1: result = 1;
            2: result = 2;
            3: result = 3;
        endcase
        if (result == 3) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        // Test 4: Priority with default
        $display("Test 4: Priority default");
        a = 99;
        priority case (a)
            1: result = 10;
            default: result = -1;
        endcase
        if (result == -1) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        // Test 5: Unique with block
        $display("Test 5: Unique block");
        a = 1;
        unique case (a)
            1: begin
                result = 5;
                result = result + 5;
            end
            2: result = 20;
        endcase
        if (result == 10) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        // Test 6: Case with expressions
        $display("Test 6: Expr case");
        a = 6;
        unique case (a)
            2*1: result = 1;
            2*2: result = 2;
            2*3: result = 3;
        endcase
        if (result == 3) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", result); fail_count++; end

        // Test 7: Multiple items
        $display("Test 7: Multi items");
        a = 4;
        priority case (a)
            1, 2: result = 12;
            3, 4: result = 34;
            default: result = 0;
        endcase
        if (result == 34) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        // Test 8: Zero match
        $display("Test 8: Zero match");
        a = 0;
        unique case (a)
            0: result = 999;
            1: result = 1;
        endcase
        if (result == 999) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
