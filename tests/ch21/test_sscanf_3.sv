/*
:name: test_sscanf_3
:description: $sscanf system function
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_3.expected
*/
// IEEE 1800-2023 §21.3.4 $sscanf system function
// Tests parsing strings with various format specifiers

module test_sscanf;
    string str;
    int a, b, c;
    int result;
    string name;
    real r;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Parse integers
        str = "10 20 30";
        result = $sscanf(str, "%d %d %d", a, b, c);
        if (result == 3 && a == 10 && b == 20 && c == 30) begin
            $display("PASS: $sscanf parsed 3 integers correctly");
            pass_count++;
        end else begin
            $display("FAIL: $sscanf - result=%0d, a=%0d, b=%0d, c=%0d", result, a, b, c);
            fail_count++;
        end

        // Test 2: Parse hex values
        str = "FF 1A 2B";
        result = $sscanf(str, "%h %h %h", a, b, c);
        if (result == 3 && a == 255 && b == 26 && c == 43) begin
            $display("PASS: $sscanf parsed hex values correctly");
            pass_count++;
        end else begin
            $display("FAIL: $sscanf hex - result=%0d, a=%0d, b=%0d, c=%0d", result, a, b, c);
            fail_count++;
        end

        // Test 3: Parse binary
        str = "1010 1111";
        result = $sscanf(str, "%b %b", a, b);
        if (result == 2 && a == 10 && b == 15) begin
            $display("PASS: $sscanf parsed binary correctly");
            pass_count++;
        end else begin
            $display("FAIL: $sscanf binary - result=%0d, a=%0d, b=%0d", result, a, b);
            fail_count++;
        end

        // Test 4: Parse octal
        str = "77 10";
        result = $sscanf(str, "%o %o", a, b);
        if (result == 2 && a == 63 && b == 8) begin
            $display("PASS: $sscanf parsed octal correctly");
            pass_count++;
        end else begin
            $display("FAIL: $sscanf octal - result=%0d, a=%0d, b=%0d", result, a, b);
            fail_count++;
        end

        // Test 5: Parse string
        str = "hello";
        result = $sscanf(str, "%s", name);
        if (result == 1 && name == "hello") begin
            $display("PASS: $sscanf parsed string correctly");
            pass_count++;
        end else begin
            $display("FAIL: $sscanf string - result=%0d, name=%s", result, name);
            fail_count++;
        end

        // Test 6: Mixed format
        str = "value=42";
        result = $sscanf(str, "value=%d", a);
        if (result == 1 && a == 42) begin
            $display("PASS: $sscanf parsed mixed format correctly");
            pass_count++;
        end else begin
            $display("FAIL: $sscanf mixed - result=%0d, a=%0d", result, a);
            fail_count++;
        end

        // Test 7: Parse with no matches
        str = "abc";
        result = $sscanf(str, "%d", a);
        if (result == 0) begin
            $display("PASS: $sscanf returned 0 for no matches");
            pass_count++;
        end else begin
            $display("FAIL: $sscanf no match - result=%0d", result);
            fail_count++;
        end

        $display("");
        $display("=== $sscanf Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
