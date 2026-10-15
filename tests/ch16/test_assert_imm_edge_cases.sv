/*
:name: test_assert_imm_edge_cases
:description: Immediate assertion edge cases
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assert_imm_edge_cases.expected
*/
// IEEE 1800-2023 §16.3: Immediate assertion edge cases
// Tests for immediate assertions

module test_assert_imm_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int x, y;
    logic valid;

    initial begin
        x = 0; y = 0; valid = 0;
        #1;

        // Test 1: Assert pass
        test_count++;
        x = 5;
        assert (x == 5) begin
            pass_count++;
            $display("Test 1 PASS: Assert x==5");
        end else begin
            $display("Test 1 FAIL: Assert unexpected");
        end

        // Test 2: Assert with message
        test_count++;
        y = 10;
        assert (y > 5) else $error("y should be > 5");
        pass_count++;
        $display("Test 2 PASS: Assert y>5");

        // Test 3: Multiple conditions
        test_count++;
        assert (x == 5 && y == 10) begin
            pass_count++;
            $display("Test 3 PASS: Multi cond");
        end else begin
            $display("Test 3 FAIL: Multi unexpected");
        end

        // Test 4: Assert false handling
        test_count++;
        begin
            static int temp = 0;
            assert (temp != 0) else temp = 1;  // Fails, so the else action runs
            if (temp == 1) begin
                pass_count++;
                $display("Test 4 PASS: False assert handled");
            end else begin
                $display("Test 4 FAIL: else action did not run");
            end
        end

        // Test 5: Assert in sequence
        test_count++;
        for (int i = 1; i <= 3; i++) begin
            assert (i > 0);
        end
        pass_count++;
        $display("Test 5 PASS: Sequence asserts");

        // Test 6: Valid signal
        test_count++;
        valid = 1;
        assert (valid) begin
            pass_count++;
            $display("Test 6 PASS: Valid assert");
        end else begin
            $display("Test 6 FAIL: Valid unexpected");
        end

        // Test 7: Expression in assert
        test_count++;
        assert (x + y == 15) begin
            pass_count++;
            $display("Test 7 PASS: Expr assert");
        end else begin
            $display("Test 7 FAIL: Expr unexpected");
        end

        // Test 8: Negation
        test_count++;
        assert (!(x == 0)) begin
            pass_count++;
            $display("Test 8 PASS: Neg assert");
        end else begin
            $display("Test 8 FAIL: Neg unexpected");
        end

        // Test 9: Comparison
        test_count++;
        assert (y >= x) begin
            pass_count++;
            $display("Test 9 PASS: Compare assert");
        end else begin
            $display("Test 9 FAIL: Compare unexpected");
        end

        // Test 10: Assume
        test_count++;
        assume (x < 100);
        pass_count++;
        $display("Test 10 PASS: Assume");

        $display("=== Assert Immediate Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
