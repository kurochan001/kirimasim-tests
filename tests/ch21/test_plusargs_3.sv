/*
:name: test_plusargs_3
:description: Test for $test$plusargs and $value$plusargs system functions
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_plusargs_3.expected
*/
// Test for $test$plusargs and $value$plusargs system functions
// IEEE 1800-2023 Section 21.6

module test_plusargs;
    int pass_count = 0;
    int fail_count = 0;

    // Variables for $value$plusargs
    string str_val;
    int int_val;
    real real_val;
    reg [31:0] hex_val;

    initial begin
        $display("=== IEEE 1800-2023 $plusargs Tests ===");

        // Test 1: $test$plusargs basic check
        $display("Test 1: $test$plusargs basic");
        if ($test$plusargs("TEST_MODE")) begin
            $display("Test 1: TEST_MODE found (expected if +TEST_MODE passed)");
            fail_count++;  // no plusargs are given when the suite runs
        end else begin
            $display("Test 1: TEST_MODE not found (expected if no +TEST_MODE)");
            pass_count++;
        end

        // Test 2: $test$plusargs with non-existent arg
        $display("Test 2: $test$plusargs non-existent");
        if ($test$plusargs("NONEXISTENT_ARG_12345")) begin
            $display("Test 2 FAIL: Found non-existent arg");
            fail_count++;
        end else begin
            $display("Test 2 PASS: Non-existent arg correctly not found");
            pass_count++;
        end

        // Test 3: $value$plusargs with string format
        $display("Test 3: $value$plusargs string format");
        str_val = "default";
        if ($value$plusargs("STR_ARG=%s", str_val)) begin
            $display("Test 3: STR_ARG found = %s", str_val);
            fail_count++;  // no plusargs are given when the suite runs
        end else begin
            $display("Test 3: STR_ARG not found, using default");
            pass_count++;
        end

        // Test 4: $value$plusargs with integer format
        $display("Test 4: $value$plusargs integer format");
        int_val = 0;
        if ($value$plusargs("INT_ARG=%d", int_val)) begin
            $display("Test 4: INT_ARG found = %0d", int_val);
            fail_count++;  // no plusargs are given when the suite runs
        end else begin
            $display("Test 4: INT_ARG not found, using default");
            pass_count++;
        end

        // Test 5: $value$plusargs with hex format
        $display("Test 5: $value$plusargs hex format");
        hex_val = 0;
        if ($value$plusargs("HEX_ARG=%h", hex_val)) begin
            $display("Test 5: HEX_ARG found = 0x%h", hex_val);
            fail_count++;  // no plusargs are given when the suite runs
        end else begin
            $display("Test 5: HEX_ARG not found, using default");
            pass_count++;
        end

        // Test 6: $value$plusargs with real format
        $display("Test 6: $value$plusargs real format");
        real_val = 0.0;
        if ($value$plusargs("REAL_ARG=%f", real_val)) begin
            $display("Test 6: REAL_ARG found = %f", real_val);
            fail_count++;  // no plusargs are given when the suite runs
        end else begin
            $display("Test 6: REAL_ARG not found, using default");
            pass_count++;
        end

        // Test 7: $test$plusargs with partial match
        $display("Test 7: $test$plusargs partial match");
        // Per IEEE 1800-2023, $test$plusargs should match prefix
        if ($test$plusargs("PARTIAL")) begin
            $display("Test 7: PARTIAL prefix found");
            fail_count++;  // no plusargs are given when the suite runs
        end else begin
            $display("Test 7: PARTIAL prefix not found");
            pass_count++;
        end

        // Summary
        $display("");
        $display("=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
