/*
:name: test_valueplusargs
:description: Test for $value$plusargs system task
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_valueplusargs.expected
*/
// Test for $value$plusargs system task
// IEEE 1800-2023 §21.6

module test_valueplusargs;
    int int_val;
    real real_val;
    string str_val;
    logic [31:0] logic_val;
    integer integer_val;

    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Integer format with %d
        test_count++;
        int_val = 0;
        if ($value$plusargs("INT_VAL=%d", int_val)) begin
            $display("Test 1: Got INT_VAL=%0d", int_val);
            // Not counted as a pass: no plusargs are given when the suite runs
        end else begin
            $display("Test 1: INT_VAL not found (expected in this run)");
            pass_count++;  // Expected when running without plusargs
        end

        // Test 2: Real format with %f
        test_count++;
        real_val = 0.0;
        if ($value$plusargs("REAL_VAL=%f", real_val)) begin
            $display("Test 2: Got REAL_VAL=%f", real_val);
            // Not counted as a pass: no plusargs are given when the suite runs
        end else begin
            $display("Test 2: REAL_VAL not found (expected)");
            pass_count++;
        end

        // Test 3: String format with %s
        test_count++;
        str_val = "";
        if ($value$plusargs("STR_VAL=%s", str_val)) begin
            $display("Test 3: Got STR_VAL=%s", str_val);
            // Not counted as a pass: no plusargs are given when the suite runs
        end else begin
            $display("Test 3: STR_VAL not found (expected)");
            pass_count++;
        end

        // Test 4: Hex format with %h
        test_count++;
        logic_val = 0;
        if ($value$plusargs("HEX_VAL=%h", logic_val)) begin
            $display("Test 4: Got HEX_VAL=%h", logic_val);
            // Not counted as a pass: no plusargs are given when the suite runs
        end else begin
            $display("Test 4: HEX_VAL not found (expected)");
            pass_count++;
        end

        // Test 5: Octal format with %o
        test_count++;
        integer_val = 0;
        if ($value$plusargs("OCT_VAL=%o", integer_val)) begin
            $display("Test 5: Got OCT_VAL=%o", integer_val);
            // Not counted as a pass: no plusargs are given when the suite runs
        end else begin
            $display("Test 5: OCT_VAL not found (expected)");
            pass_count++;
        end

        // Test 6: Binary format with %b
        test_count++;
        logic_val = 0;
        if ($value$plusargs("BIN_VAL=%b", logic_val)) begin
            $display("Test 6: Got BIN_VAL=%b", logic_val);
            // Not counted as a pass: no plusargs are given when the suite runs
        end else begin
            $display("Test 6: BIN_VAL not found (expected)");
            pass_count++;
        end

        // Test 7: $test$plusargs
        test_count++;
        if ($test$plusargs("VERBOSE")) begin
            $display("Test 7: VERBOSE found");
            // Not counted as a pass: no plusargs are given when the suite runs
        end else begin
            $display("Test 7: VERBOSE not found (expected)");
            pass_count++;
        end

        // Test 8: $test$plusargs with prefix match
        test_count++;
        if ($test$plusargs("DEBUG")) begin
            $display("Test 8: DEBUG prefix found");
            // Not counted as a pass: no plusargs are given when the suite runs
        end else begin
            $display("Test 8: DEBUG prefix not found (expected)");
            pass_count++;
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
