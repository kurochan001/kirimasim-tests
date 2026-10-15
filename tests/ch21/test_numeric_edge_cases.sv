/*
:name: test_numeric_edge_cases
:description: $sscanf input fields with underscores, signs, prefixes and too many digits
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_numeric_edge_cases.expected
*/
// $sscanf input fields with underscores, signs, prefixes and too many digits
module test_numeric_edge_cases;
    int errors;
    int int_val;
    int result;

    // Each input field may hold the characters listed for its conversion in
    // 21.3.4.3 (underscores included) and ends at the first character that
    // does not belong; a value too wide for the argument keeps its LSBs.
    task automatic check(string label, int want);
        if (result == 1 && int_val == want) begin
            $display("PASS: %s: %0d", label, int_val);
        end else begin
            $display("FAIL: %s: result=%0d, val=%0d", label, result, int_val);
            errors++;
        end
    endtask

    initial begin
        errors = 0;

        result = $sscanf("1_000_000", "%d", int_val);
        check("Underscore separated decimal", 1000000);
        result = $sscanf("FF_FF", "%h", int_val);
        check("Hex with underscores", 32'h0000FFFF);
        result = $sscanf("1010_1010", "%b", int_val);
        check("Binary with underscores", 32'h000000AA);
        result = $sscanf("0000123", "%d", int_val);
        check("Leading zeros decimal", 123);
        result = $sscanf("-42", "%d", int_val);
        check("Signed negative", -42);
        result = $sscanf("+999", "%d", int_val);
        check("Positive sign", 999);
        result = $sscanf("0o777", "%o", int_val);
        check("Octal field ends at the letter o", 0);
        result = $sscanf("DEADBEEF", "%h", int_val);
        check("Large hex", 32'hDEADBEEF);
        result = $sscanf("0", "%d", int_val);
        check("Zero value", 0);
        result = $sscanf("4294967295", "%d", int_val);
        check("2**32-1 into an int", -1);
        result = $sscanf("7", "%d", int_val);
        check("Single digit", 7);
        result = $sscanf("aAbBcCdDeEfF", "%h", int_val);
        check("Mixed case hex keeps the LSBs", 32'hCCDDEEFF);

        $display("");
        if (errors == 0) begin
            $display("TEST PASSED: All numeric edge case tests completed");
        end else begin
            $display("TEST FAILED: %0d errors", errors);
        end
        $finish;
    end
endmodule
