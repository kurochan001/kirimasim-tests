/*
:name: test_scanf_functions
:description: Test for IEEE 1800-2023 §21.3.1: $sscanf system function
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_scanf_functions.expected
*/
// Test for IEEE 1800-2023 §21.3.4.3: $sscanf system function

module test_scanf_functions;
    int pass_count = 0;
    int fail_count = 0;

    string input_str;
    int int_val, int_val2, int_val3;
    real real_val;
    string str_val;
    int num_matched;
    logic [31:0] hex_val;
    logic [31:0] bin_val;

    initial begin
        $display("=== $sscanf System Function Test ===");

        // Test basic integer parsing
        input_str = "12345";
        num_matched = $sscanf(input_str, "%d", int_val);
        if (num_matched == 1 && int_val == 12345) begin
            $display("PASS: $sscanf(\"%s\", \"%%d\") = %0d, matched=%0d", input_str, int_val, num_matched);
            pass_count++;
        end else begin
            $display("FAIL: $sscanf expected int_val=12345, got %0d", int_val);
            fail_count++;
        end

        // Test multiple integers
        input_str = "10 20 30";
        num_matched = $sscanf(input_str, "%d %d %d", int_val, int_val2, int_val3);
        if (num_matched == 3 && int_val == 10 && int_val2 == 20 && int_val3 == 30) begin
            $display("PASS: Multiple integers: %0d, %0d, %0d", int_val, int_val2, int_val3);
            pass_count++;
        end else begin
            $display("FAIL: Multiple integers parsing failed");
            fail_count++;
        end

        // Test hexadecimal parsing
        input_str = "DEADBEEF";
        num_matched = $sscanf(input_str, "%h", hex_val);
        if (num_matched == 1 && hex_val == 32'hDEADBEEF) begin
            $display("PASS: $sscanf hex: 0x%h", hex_val);
            pass_count++;
        end else begin
            $display("FAIL: $sscanf hex expected DEADBEEF, got %h", hex_val);
            fail_count++;
        end

        // "0x" is not a prefix for %h: x is a hexadecimal digit character, so
        // the input reads as the digits 0, x, C, A, F, E (21.3.4.3)
        input_str = "0xCAFE";
        num_matched = $sscanf(input_str, "%h", hex_val);
        if (num_matched == 1 && hex_val === 32'h0x_cafe) begin
            $display("PASS: $sscanf hex with prefix: 0x%h", hex_val);
            pass_count++;
        end else begin
            $display("FAIL: $sscanf hex with prefix failed");
            fail_count++;
        end

        // Test binary parsing
        input_str = "10101010";
        num_matched = $sscanf(input_str, "%b", bin_val);
        if (num_matched == 1 && bin_val == 8'hAA) begin
            $display("PASS: $sscanf binary: %b = 0x%h", bin_val, bin_val);
            pass_count++;
        end else begin
            $display("FAIL: $sscanf binary expected AA, got %h", bin_val);
            fail_count++;
        end

        // Test string parsing
        input_str = "Hello World";
        num_matched = $sscanf(input_str, "%s", str_val);
        if (num_matched >= 1) begin
            $display("PASS: $sscanf string: \"%s\"", str_val);
            pass_count++;
        end else begin
            $display("FAIL: $sscanf string failed");
            fail_count++;
        end

        // Test negative number
        input_str = "-9876";
        num_matched = $sscanf(input_str, "%d", int_val);
        if (num_matched == 1 && int_val == -9876) begin
            $display("PASS: $sscanf negative: %0d", int_val);
            pass_count++;
        end else begin
            $display("FAIL: $sscanf negative expected -9876, got %0d", int_val);
            fail_count++;
        end

        // Test octal parsing
        input_str = "777";
        num_matched = $sscanf(input_str, "%o", int_val);
        if (num_matched == 1 && int_val == 9'o777) begin
            $display("PASS: $sscanf octal: %o = %0d", int_val, int_val);
            pass_count++;
        end else begin
            $display("FAIL: $sscanf octal expected 511, got %0d", int_val);
            fail_count++;
        end

        // Test mixed format
        input_str = "value=42";
        num_matched = $sscanf(input_str, "value=%d", int_val);
        if (num_matched == 1 && int_val == 42) begin
            $display("PASS: $sscanf mixed format: %0d", int_val);
            pass_count++;
        end else begin
            $display("FAIL: $sscanf mixed format failed");
            fail_count++;
        end

        // Summary
        $display("\n=== $sscanf System Function Test Summary ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end
endmodule
