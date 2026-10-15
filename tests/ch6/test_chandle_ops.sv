/*
:name: test_chandle_ops
:description: Test chandle null checks and operations
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.14
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_chandle_ops.expected
*/
// Test chandle null checks and operations
module test_chandle_ops;
    chandle h1, h2, h3;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Default chandle is null
        if (h1 == null) begin
            $display("PASS: Test 1 - Default chandle is null");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Default chandle should be null");
            fail_count++;
        end

        // Test 2: Chandle explicit null assignment
        h2 = null;
        if (h2 == null) begin
            $display("PASS: Test 2 - Explicit null assignment");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Explicit null assignment failed");
            fail_count++;
        end

        // Test 3: Chandle equality (both null)
        h1 = null;
        h2 = null;
        if (h1 == h2) begin
            $display("PASS: Test 3 - Two null chandles are equal");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Two null chandles should be equal");
            fail_count++;
        end

        // Test 4: Chandle assignment
        h3 = h1;
        if (h3 == h1) begin
            $display("PASS: Test 4 - Chandle assignment");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Chandle assignment failed");
            fail_count++;
        end

        // Test 5: Chandle not equal to non-null check pattern
        h1 = null;
        if (!(h1 != null)) begin
            $display("PASS: Test 5 - Chandle != null is false for null");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Chandle != null check failed");
            fail_count++;
        end

        $display("\nSummary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
