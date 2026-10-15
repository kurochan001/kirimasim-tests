/*
:name: test_case_inside
:description: Case Inside Tests
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_case_inside.expected
*/
// IEEE 1800-2023 Section 12.5.4 - Case Inside Tests
// Tests: Case inside with exact values, multiple matches

module test_case_inside;
    int pass_count = 0;
    int fail_count = 0;

    logic [3:0] val;
    string result;

    initial begin
        $display("=== IEEE 1800-2023 Case Inside Tests ===");

        // Test 1: Exact match zero
        $display("Test 1: Exact match zero");
        val = 4'd0;
        case (val) inside
            0: result = "zero";
            1, 2, 3: result = "low";
            default: result = "other";
        endcase
        if (result == "zero") begin
            $display("Test 1 PASS: val=%0d -> %s", val, result);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %s", result);
            fail_count++;
        end

        // Test 2: Multiple values match
        $display("Test 2: Multiple values match");
        val = 4'd2;
        case (val) inside
            0: result = "zero";
            1, 2, 3: result = "low";
            default: result = "other";
        endcase
        if (result == "low") begin
            $display("Test 2 PASS: val=%0d -> %s", val, result);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %s", result);
            fail_count++;
        end

        // Test 3: Odd values
        $display("Test 3: Odd values");
        val = 4'd7;
        case (val) inside
            1, 3, 5, 7, 9, 11, 13, 15: result = "odd";
            0, 2, 4, 6, 8, 10, 12, 14: result = "even";
        endcase
        if (result == "odd") begin
            $display("Test 3 PASS: val=%0d -> %s", val, result);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %s", result);
            fail_count++;
        end

        // Test 4: Even values
        $display("Test 4: Even values");
        val = 4'd8;
        case (val) inside
            1, 3, 5, 7, 9, 11, 13, 15: result = "odd";
            0, 2, 4, 6, 8, 10, 12, 14: result = "even";
        endcase
        if (result == "even") begin
            $display("Test 4 PASS: val=%0d -> %s", val, result);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: got %s", result);
            fail_count++;
        end

        // Test 5: Default case
        $display("Test 5: Default case");
        val = 4'd15;
        case (val) inside
            0, 1, 2, 3: result = "low";
            4, 5, 6, 7: result = "mid";
            default: result = "default";
        endcase
        if (result == "default") begin
            $display("Test 5 PASS: val=%0d -> %s", val, result);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: got %s", result);
            fail_count++;
        end

        // Test 6: First branch match
        $display("Test 6: First branch match");
        val = 4'd1;
        case (val) inside
            0, 1, 2, 3: result = "first";
            4, 5, 6, 7: result = "second";
            default: result = "default";
        endcase
        if (result == "first") begin
            $display("Test 6 PASS: val=%0d -> %s", val, result);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: got %s", result);
            fail_count++;
        end

        // Test 7: Second branch match
        $display("Test 7: Second branch match");
        val = 4'd5;
        case (val) inside
            0, 1, 2, 3: result = "first";
            4, 5, 6, 7: result = "second";
            default: result = "default";
        endcase
        if (result == "second") begin
            $display("Test 7 PASS: val=%0d -> %s", val, result);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: got %s", result);
            fail_count++;
        end

        // Test 8: Max value default
        $display("Test 8: Max value");
        val = 4'd14;
        case (val) inside
            0, 2, 4, 6, 8, 10, 12, 14: result = "even";
            default: result = "default";
        endcase
        if (result == "even") begin
            $display("Test 8 PASS: val=%0d -> %s", val, result);
            pass_count++;
        end else begin
            $display("Test 8 FAIL: got %s", result);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
