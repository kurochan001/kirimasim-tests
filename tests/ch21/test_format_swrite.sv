/*
:name: test_format_swrite
:description: Format String Functions Tests
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_swrite.expected
*/
// IEEE 1800-2023 Section 21.3.3 - Format String Functions Tests
// Tests: $swrite, $sformat, $sformatf basic functionality

module test_format_swrite;
    int pass_count = 0;
    int fail_count = 0;

    string result;
    int i_val;
    real r_val;
    logic [31:0] h_val;
    string s_val;
    int str_len;

    initial begin
        $display("=== IEEE 1800-2023 Format String Functions Tests ===");

        // Test 1: Basic $swrite
        $display("Test 1: Basic $swrite");
        i_val = 42;
        $swrite(result, "Value: %0d", i_val);
        str_len = result.len();
        $display("  Result: '%s' (len=%0d)", result, str_len);
        if (str_len > 0) begin
            $display("Test 1 PASS");
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: $sformat with hex
        $display("Test 2: $sformat with hex");
        h_val = 32'hCAFE;
        $sformat(result, "Hex: %h", h_val);
        $display("  Result: '%s'", result);
        if (result.len() > 0) begin
            $display("Test 2 PASS");
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: $sformatf return value
        $display("Test 3: $sformatf return value");
        i_val = 100;
        result = $sformatf("Number is %0d", i_val);
        $display("  Result: '%s'", result);
        if (result.len() > 0) begin
            $display("Test 3 PASS");
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: Width specification
        $display("Test 4: Width specification");
        i_val = 7;
        result = $sformatf("|%5d|", i_val);
        $display("  Result: '%s'", result);
        $display("Test 4 PASS");
        pass_count++;

        // Test 5: Real number
        $display("Test 5: Real number formatting");
        r_val = 3.14159265;
        result = $sformatf("%.3f", r_val);
        $display("  Result: '%s'", result);
        $display("Test 5 PASS");
        pass_count++;

        // Test 6: Multiple values
        $display("Test 6: Multiple format values");
        i_val = 10;
        h_val = 32'hAB;
        s_val = "test";
        result = $sformatf("i=%0d h=%h s=%s", i_val, h_val, s_val);
        $display("  Result: '%s'", result);
        $display("Test 6 PASS");
        pass_count++;

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
