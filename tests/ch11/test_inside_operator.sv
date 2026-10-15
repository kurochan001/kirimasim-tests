/*
:name: test_inside_operator
:description: Inside Operator Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inside_operator.expected
*/
// IEEE 1800-2023 Section 11.4.13 - Inside Operator Tests
// Tests: inside operator for set membership

module test_inside_operator;
    int pass_count = 0;
    int fail_count = 0;
    int hits = 0;

    logic [7:0] val;
    logic result;
    int i_val;

    initial begin
        $display("=== IEEE 1800-2023 Inside Operator Test ===");

        // Test 1: Simple set membership
        $display("Test 1: Simple set membership");
        val = 8'h05;
        result = val inside {8'h01, 8'h03, 8'h05, 8'h07};
        $display("  5 inside {1,3,5,7} = %b", result);
        if (result == 1) begin
            $display("Test 1 PASS");
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: Not in set
        $display("Test 2: Not in set");
        val = 8'h04;
        result = val inside {8'h01, 8'h03, 8'h05, 8'h07};
        $display("  4 inside {1,3,5,7} = %b", result);
        if (result == 0) begin
            $display("Test 2 PASS");
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Range membership
        $display("Test 3: Range membership");
        val = 8'h50;
        result = val inside {[8'h40:8'h60]};
        $display("  50 inside {[40:60]} = %b", result);
        if (result == 1) begin
            $display("Test 3 PASS");
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: Outside range
        $display("Test 4: Outside range");
        val = 8'h30;
        result = val inside {[8'h40:8'h60]};
        $display("  30 inside {[40:60]} = %b", result);
        if (result == 0) begin
            $display("Test 4 PASS");
            pass_count++;
        end else begin
            $display("Test 4 FAIL");
            fail_count++;
        end

        // Test 5: Mixed values and ranges
        $display("Test 5: Mixed values and ranges");
        val = 8'hAA;
        result = val inside {8'h00, [8'hA0:8'hAF], 8'hFF};
        $display("  AA inside {00, [A0:AF], FF} = %b", result);
        if (result == 1) begin
            $display("Test 5 PASS");
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: Integer inside
        $display("Test 6: Integer inside");
        i_val = 42;
        result = i_val inside {10, 20, 30, 40, 42, 50};
        $display("  42 inside {10,20,30,40,42,50} = %b", result);
        if (result == 1) begin
            $display("Test 6 PASS");
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: Empty match
        $display("Test 7: Boundary values");
        val = 8'h40;  // exactly at boundary
        result = val inside {[8'h40:8'h60]};
        $display("  40 inside {[40:60]} = %b (boundary)", result);
        val = 8'h60;
        result = val inside {[8'h40:8'h60]};
        $display("  60 inside {[40:60]} = %b (boundary)", result);
        if (result == 1) begin
            $display("Test 7 PASS");
            pass_count++;
        end else begin
            $display("Test 7 FAIL");
            fail_count++;
        end

        // Test 8: Multiple ranges
        $display("Test 8: Multiple ranges");
        val = 8'h85;
        result = val inside {[8'h00:8'h0F], [8'h80:8'h8F], [8'hF0:8'hFF]};
        $display("  85 inside {[00:0F],[80:8F],[F0:FF]} = %b", result);
        if (result == 1) begin
            $display("Test 8 PASS");
            pass_count++;
        end else begin
            $display("Test 8 FAIL");
            fail_count++;
        end

        // Test 9: Loop with inside
        $display("Test 9: Loop with inside");
        for (int i = 0; i < 8; i++) begin
            val = i * 16;
            result = val inside {[8'h20:8'h40]};
            if (result) begin
                $display("  val=%h is inside", val);
                hits++;
            end
        end
        // 0x20, 0x30 and 0x40 are inside [0x20:0x40]
        if (hits == 3) begin
            $display("Test 9 PASS");
            pass_count++;
        end else begin
            $display("Test 9 FAIL");
            fail_count++;
        end

        // Test 10: Single value range
        $display("Test 10: Single value range");
        val = 8'h55;
        result = val inside {[8'h55:8'h55]};
        $display("  55 inside {[55:55]} = %b", result);
        if (result == 1) begin
            $display("Test 10 PASS");
            pass_count++;
        end else begin
            $display("Test 10 FAIL");
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
