/*
:name: test_swrite_output
:description: $swrite, $swriteb, $swriteo and $swriteh write formatted text to a string
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3 21.2.1.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_swrite_output.expected
*/
// $swrite, $swriteb, $swriteo and $swriteh write the formatted text into their
// first argument (21.3.3). Without a format, the b, o and h forms show every
// digit of the 32-bit value, leading zeros included (21.2.1.2).

module test_swrite_output;
    string result;
    string formatted_str;
    integer value;
    real real_val;
    int errors = 0;

    initial begin
        $display("=== Testing $swrite Output Argument Handling ===");

        // Test 1: Basic $swrite
        value = 42;
        $swrite(result, "The value is %0d", value);
        $display("Test 1 - Basic $swrite: '%s'", result);
        if (result != "The value is 42") begin
            $display("Test 1 failed: expected 'The value is 42', got '%s'", result);
            errors++;
        end

        // Test 2: $swriteb (binary)
        value = 10;
        $swriteb(result, value);
        $display("Test 2 - $swriteb: '%s'", result);
        if (result != "00000000000000000000000000001010") begin
            $display("Test 2 failed: got '%s'", result);
            errors++;
        end

        // Test 3: $swriteo (octal)
        value = 64;
        $swriteo(result, value);
        $display("Test 3 - $swriteo: '%s'", result);
        if (result != "00000000100") begin
            $display("Test 3 failed: got '%s'", result);
            errors++;
        end

        // Test 4: $swriteh (hex)
        value = 255;
        $swriteh(result, value);
        $display("Test 4 - $swriteh: '%s'", result);
        if (result != "000000ff") begin
            $display("Test 4 failed: got '%s'", result);
            errors++;
        end

        // Test 5: Multiple format specifiers
        value = 123;
        real_val = 45.67;
        $swrite(formatted_str, "Int: %0d, Real: %.2f, Hex: %h", value, real_val, value);
        $display("Test 5 - Multiple formats: '%s'", formatted_str);
        if (formatted_str != "Int: 123, Real: 45.67, Hex: 0000007b") begin
            $display("Test 5 failed");
            errors++;
        end

        // Test 6: Overwriting existing string
        result = "Initial value";
        $swrite(result, "Overwritten");
        $display("Test 6 - Overwrite: '%s'", result);
        if (result != "Overwritten") begin
            $display("Test 6 failed: expected 'Overwritten', got '%s'", result);
            errors++;
        end

        if (errors == 0) $display("=== Test Completed Successfully ===");
        else $display("=== %0d tests failed ===", errors);
        $finish;
    end
endmodule
