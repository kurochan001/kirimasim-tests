/*
:name: test_scanf_utils
:description: Test for scanf utilities
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scanf_utils.expected
*/
// Test for scanf utilities
// IEEE 1800-2023 §21.3.4

module test_scanf_utils;
    string s;
    int result, val1, val2, val3;
    real r;
    string str;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Integer parsing
        test_count++;
        s = "42";
        result = $sscanf(s, "%d", val1);
        if (result == 1 && val1 == 42) begin
            $display("Test 1: Parse '42' = %0d PASS", val1);
            pass_count++;
        end else begin
            $display("Test 1: Parse '42' FAIL");
        end

        // Test 2: Multiple integers
        test_count++;
        s = "10 20 30";
        result = $sscanf(s, "%d %d %d", val1, val2, val3);
        if (result == 3 && val1 == 10 && val2 == 20 && val3 == 30) begin
            $display("Test 2: Parse '10 20 30' = %0d %0d %0d PASS", val1, val2, val3);
            pass_count++;
        end else begin
            $display("Test 2: Parsed %0d values FAIL", result);
        end

        // Test 3: Hex parsing
        test_count++;
        s = "FF";
        result = $sscanf(s, "%h", val1);
        if (result == 1 && val1 == 255) begin
            $display("Test 3: Parse 'FF' hex = %0d PASS", val1);
            pass_count++;
        end else begin
            $display("Test 3: Parse hex FAIL");
        end

        // Test 4: Binary parsing
        test_count++;
        s = "1010";
        result = $sscanf(s, "%b", val1);
        if (result == 1 && val1 == 10) begin
            $display("Test 4: Parse '1010' binary = %0d PASS", val1);
            pass_count++;
        end else begin
            $display("Test 4: Parse binary FAIL");
        end

        // Test 5: Octal parsing
        test_count++;
        s = "77";
        result = $sscanf(s, "%o", val1);
        if (result == 1 && val1 == 63) begin
            $display("Test 5: Parse '77' octal = %0d PASS", val1);
            pass_count++;
        end else begin
            $display("Test 5: Parse octal FAIL");
        end

        // Test 6: String parsing
        test_count++;
        s = "hello";
        result = $sscanf(s, "%s", str);
        if (result == 1 && str == "hello") begin
            $display("Test 6: Parse 'hello' = '%s' PASS", str);
            pass_count++;
        end else begin
            $display("Test 6: Parse string FAIL");
        end

        // Test 7: Mixed format
        test_count++;
        s = "100 hello";
        result = $sscanf(s, "%d %s", val1, str);
        if (result == 2 && val1 == 100 && str == "hello") begin
            $display("Test 7: Parse '100 hello' = %0d '%s' PASS", val1, str);
            pass_count++;
        end else begin
            $display("Test 7: Mixed parse FAIL");
        end

        // Test 8: Negative number
        test_count++;
        s = "-123";
        result = $sscanf(s, "%d", val1);
        if (result == 1 && val1 == -123) begin
            $display("Test 8: Parse '-123' = %0d PASS", val1);
            pass_count++;
        end else begin
            $display("Test 8: Parse negative FAIL");
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
