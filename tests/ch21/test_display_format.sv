/*
:name: test_display_format
:description: $display Format (§21.2.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.1 21.2.1.2
:oracle: spec
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_display_format.expected
*/
// IEEE 1800-2023 $display Format (§21.2.1)
// Tests various format specifiers

module test_display_format;
    initial begin
        static int i_val = 42;
        static logic [7:0] l_val = 8'hAB;
        static real r_val = 3.14159;
        static string s_val = "hello";
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Decimal format
        $display("Testing format specifiers...");

        // Test 2: Various formats
        $display("Decimal: %d", i_val);
        $display("Hex: %h", l_val);
        $display("Binary: %b", l_val);
        $display("Octal: %o", l_val);
        $display("Real: %f", r_val);
        $display("String: %s", s_val);

        // Test 3: Width specifiers
        $display("Width 8: [%8d]", i_val);
        // A field width wider than the value pads hexadecimal with zeros
        // (21.2.1.2).
        $display("Width 4 hex: [%4h]", l_val);


        // All format tests passed if we reach here
        $display("");
        $display("PASS: All format specifiers executed without error");
        pass_count = 1;

        $display("");
        $display("=== Display Format Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
