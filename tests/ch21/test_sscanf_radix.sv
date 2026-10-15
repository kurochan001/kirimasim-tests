/*
:name: test_sscanf_radix
:description: $sscanf with %h, %o, %b and %d, one and several fields
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_radix.expected
*/
// $sscanf with %h, %o, %b and %d, one and several fields
module test_sscanf_radix;
    string hex_str, oct_str, bin_str, dec_str;
    int hex_val, oct_val, bin_val, dec_val;
    int count;
    int errors;

    initial begin
        errors = 0;

        // Test 1: Hexadecimal parsing
        $display("Test 1: Hexadecimal parsing");
        hex_str = "FF";
        count = $sscanf(hex_str, "%h", hex_val);
        if (hex_val == 255 && count == 1) begin
            $display("  PASS: hex FF = %0d", hex_val);
        end else begin
            $display("  FAIL: hex parsing result: %0d (count=%0d)", hex_val, count);
            errors++;
        end

        // Test 2: Octal parsing
        $display("Test 2: Octal parsing");
        oct_str = "77";
        count = $sscanf(oct_str, "%o", oct_val);
        if (oct_val == 63 && count == 1) begin
            $display("  PASS: oct 77 = %0d", oct_val);
        end else begin
            $display("  FAIL: oct parsing result: %0d (count=%0d)", oct_val, count);
            errors++;
        end

        // Test 3: Binary parsing
        $display("Test 3: Binary parsing");
        bin_str = "1010";
        count = $sscanf(bin_str, "%b", bin_val);
        if (bin_val == 10 && count == 1) begin
            $display("  PASS: bin 1010 = %0d", bin_val);
        end else begin
            $display("  FAIL: bin parsing result: %0d (count=%0d)", bin_val, count);
            errors++;
        end

        // Test 4: Decimal parsing
        $display("Test 4: Decimal parsing");
        dec_str = "12345";
        count = $sscanf(dec_str, "%d", dec_val);
        if (dec_val == 12345 && count == 1) begin
            $display("  PASS: dec 12345 = %0d", dec_val);
        end else begin
            $display("  FAIL: dec parsing result: %0d (count=%0d)", dec_val, count);
            errors++;
        end

        // Test 5: Mixed format parsing
        $display("Test 5: Mixed format parsing");
        begin
            static string mixed = "100 20 010";
            int d_val, h_val, o_val;
            count = $sscanf(mixed, "%d %h %o", d_val, h_val, o_val);
            $display("  Parsed: dec=%0d, hex=%0d, oct=%0d (count=%0d)",
                d_val, h_val, o_val, count);
            if (count != 3 || d_val != 100 || h_val != 32 || o_val != 8) errors++;
        end

        // Test 6: Negative decimal
        $display("Test 6: Negative decimal");
        dec_str = "-42";
        count = $sscanf(dec_str, "%d", dec_val);
        $display("  Negative: %0d (count=%0d)", dec_val, count);
        if (count != 1 || dec_val != -42) errors++;

        $display("");
        if (errors == 0) begin
            $display("TEST PASSED: sscanf radix tests completed");
        end else begin
            $display("TEST FAILED: %0d errors", errors);
        end
        $finish;
    end
endmodule
