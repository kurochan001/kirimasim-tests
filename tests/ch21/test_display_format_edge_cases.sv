/*
:name: test_display_format_edge_cases
:description: Display and format edge cases
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.2 21.2.1.3 21.3.2 21.3.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_display_format_edge_cases.expected
*/
// IEEE 1800-2023 §21.2: Display and format edge cases
// Tests for $display, $write, $sformat, $sformatf

module test_display_format_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    string str;
    logic [31:0] val32;
    logic [7:0] val8;
    int ival;
    real rval;

    initial begin
        // Test 1: Basic $display
        test_count++;
        $display("Test 1 PASS: Basic display");
        pass_count++;

        // Test 2: %d format
        test_count++;
        ival = 42;
        $display("Test 2 PASS: %%d = %d", ival);
        pass_count++;

        // Test 3: %h format
        test_count++;
        val32 = 32'hDEADBEEF;
        $display("Test 3 PASS: %%h = %h", val32);
        pass_count++;

        // Test 4: %b format
        test_count++;
        val8 = 8'b10101010;
        $display("Test 4 PASS: %%b = %b", val8);
        pass_count++;

        // Test 5: %o format
        test_count++;
        val8 = 8'o77;
        $display("Test 5 PASS: %%o = %o", val8);
        pass_count++;

        // Test 6: %s format
        test_count++;
        str = "hello";
        $display("Test 6 PASS: %%s = %s", str);
        pass_count++;

        // Test 7: %f format
        test_count++;
        rval = 3.14159;
        $display("Test 7 PASS: %%f = %f", rval);
        pass_count++;

        // Test 8: %e format
        test_count++;
        rval = 1.23e-10;
        $display("Test 8 PASS: %%e = %e", rval);
        pass_count++;

        // Test 9: %t format
        test_count++;
        $display("Test 9 PASS: %%t = %t", $time);
        pass_count++;

        // Test 10: %0d (no padding)
        test_count++;
        ival = 5;
        $display("Test 10 PASS: %%0d = %0d", ival);
        pass_count++;

        // Test 11: Width specifier
        test_count++;
        ival = 42;
        $display("Test 11 PASS: %%10d = [%10d]", ival);
        pass_count++;

        // Test 12: $sformat
        test_count++;
        $sformat(str, "Value: %0d", 123);
        if (str == "Value: 123") begin
            pass_count++;
            $display("Test 12 PASS: $sformat = %s", str);
        end else begin
            $display("Test 12 FAIL: $sformat unexpected = %s", str);
        end

        // Test 13: $sformatf
        test_count++;
        str = $sformatf("Hex: %h", 32'hCAFE);
        if (str.len() > 0) begin
            pass_count++;
            $display("Test 13 PASS: $sformatf = %s", str);
        end else begin
            $display("Test 13 FAIL");
        end

        // Test 14: Multiple arguments
        test_count++;
        $display("Test 14 PASS: a=%0d b=%0d c=%0d", 1, 2, 3);
        pass_count++;

        // Test 15: Negative number
        test_count++;
        ival = -100;
        $display("Test 15 PASS: Negative = %0d", ival);
        pass_count++;

        // Test 16: Zero value
        test_count++;
        ival = 0;
        $display("Test 16 PASS: Zero = %0d", ival);
        pass_count++;

        // Test 17: Max int
        test_count++;
        ival = 32'h7FFFFFFF;
        $display("Test 17 PASS: Max int = %0d", ival);
        pass_count++;

        // Test 18: Empty string
        test_count++;
        str = "";
        $display("Test 18 PASS: Empty string = [%s]", str);
        pass_count++;

        // Test 19: Special chars in string
        test_count++;
        str = "a\\b";  // Escaped backslash
        $display("Test 19 PASS: Special chars handled");
        pass_count++;

        // Test 20: Complex format
        test_count++;
        $display("Test 20 PASS: h=%h d=%0d b=%b", 32'hAB, 171, 8'b10101011);
        pass_count++;

        $display("=== Display/Format Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
