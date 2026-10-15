/*
:name: test_format_width_2
:description: Explicit field widths in %d, %h, %s and %f
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.2 21.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_width_2.expected
*/
// Explicit field widths in %d, %h, %s and %f

module test_format_width;
    int pass_count = 0;
    int total_tests = 0;

    // Test variables
    int i;
    string str;
    string result;
    logic [31:0] lv;
    real r;

    initial begin
        // Test 1: %10d right-aligned
        total_tests++;
        i = 42;
        $sformat(result, "%10d", i);
        if (result == "        42") begin
            pass_count++;
            $display("PASS: %%10d right-aligned");
        end else $display("FAIL: %%10d, got '%s' (len=%0d)", result, result.len());

        // Test 2: %5d with larger number
        total_tests++;
        i = 12345;
        $sformat(result, "%5d", i);
        if (result == "12345") begin
            pass_count++;
            $display("PASS: %%5d exact fit");
        end else $display("FAIL: %%5d exact, got '%s'", result);

        // Test 3: %3d overflow (number wider than field)
        total_tests++;
        i = 12345;
        $sformat(result, "%3d", i);
        // Should not truncate, expands
        if (result == "12345") begin
            pass_count++;
            $display("PASS: %%3d overflow");
        end else $display("FAIL: %%3d overflow, got '%s'", result);

        // Test 4: %8h hex with width
        total_tests++;
        lv = 32'hAB;
        $sformat(result, "%8h", lv);
        if (result == "000000ab") begin
            pass_count++;
            $display("PASS: %%8h with padding");
        end else $display("FAIL: %%8h, got '%s'", result);

        // Test 5: %10s string width
        total_tests++;
        str = "Hello";
        $sformat(result, "%10s", str);
        if (result == "     Hello") begin
            pass_count++;
            $display("PASS: %%10s right-aligned");
        end else $display("FAIL: %%10s, got '%s' (len=%0d)", result, result.len());

        // Test 9: negative with width
        total_tests++;
        i = -42;
        $sformat(result, "%10d", i);
        if (result == "       -42") begin
            pass_count++;
            $display("PASS: %%10d negative");
        end else $display("FAIL: %%10d negative, got '%s'", result);

        // Test 11: combined widths
        total_tests++;
        i = 1;
        $sformat(result, "[%5d][%5d]", i, i*10);
        if (result == "[    1][   10]") begin
            pass_count++;
            $display("PASS: combined widths");
        end else $display("FAIL: combined, got '%s'", result);

        // Test 12: %1d minimal width
        total_tests++;
        i = 5;
        $sformat(result, "%1d", i);
        if (result == "5") begin
            pass_count++;
            $display("PASS: %%1d minimal");
        end else $display("FAIL: %%1d, got '%s'", result);

        // Test 13: large width
        total_tests++;
        i = 99;
        $sformat(result, "%20d", i);
        if (result == "                  99") begin
            pass_count++;
            $display("PASS: %%20d large width (len=%0d)", result.len());
        end else $display("FAIL: %%20d, got '%s' (len=%0d)", result, result.len());

        // Test 14: width with real
        total_tests++;
        r = 3.14;
        $sformat(result, "%15f", r);
        if (result == "       3.140000") begin
            pass_count++;
            $display("PASS: %%15f: '%s'", result);
        end else $display("FAIL: %%15f");

        $display("PASS: format_width (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
