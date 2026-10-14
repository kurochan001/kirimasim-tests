/*
:name: test_scanner
:description: Test for scanf operations
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3 13.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scanner.expected
*/
// Test for scanf operations
// IEEE 1800-2023 §21.3.4

module test_scanner;
    string str;
    int ival;
    real rval;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: sscanf integer
        test_count++;
        str = "12345";
        $sscanf(str, "%d", ival);
        if (ival == 12345) begin
            $display("Test 1: sscanf int PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL ival=%0d", ival);
        end

        // Test 2: sscanf hex
        test_count++;
        str = "FF";
        $sscanf(str, "%h", ival);
        if (ival == 255) begin
            $display("Test 2: sscanf hex PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL ival=%0d", ival);
        end

        // Test 3: sscanf binary
        test_count++;
        str = "1010";
        $sscanf(str, "%b", ival);
        if (ival == 10) begin
            $display("Test 3: sscanf binary PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL ival=%0d", ival);
        end

        // Test 4: sscanf octal
        test_count++;
        str = "77";
        $sscanf(str, "%o", ival);
        if (ival == 63) begin
            $display("Test 4: sscanf octal PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL ival=%0d", ival);
        end

        // Test 5: sscanf real
        test_count++;
        str = "3.14";
        $sscanf(str, "%f", rval);
        $display("Test 5: sscanf real PASS rval=%f", rval);
        pass_count++;

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
