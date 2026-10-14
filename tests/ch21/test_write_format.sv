/*
:name: test_write_format
:description: Test for $write format specifiers (IEEE 1800-2023 §21.2.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_write_format.expected
*/
// Test for $write format specifiers (IEEE 1800-2023 §21.2.1)
// Verifies that $write supports the same format specifiers as $display
// but does not append a newline

module test_write_format;
    int x = 42;
    int y = 255;
    int neg = -10;
    string s = "hello";
    real r = 3.14159;
    logic [7:0] vec = 8'hAA;

    int pass_count = 0;
    int fail_count = 0;

    initial begin
        $display("=== $write Format Specifier Test (IEEE 1800-2023 §21.2.1) ===");

        // Test 1: Decimal format %d and %0d
        $display("\n--- Test 1: Decimal format ---");
        $write("x=%d", x);
        $display("");  // Add newline
        $write("x=%0d", x);
        $display(" (minimum width)");
        pass_count++;

        // Test 2: Hexadecimal format %h and %x
        $display("\n--- Test 2: Hexadecimal format ---");
        $write("y=%h", y);
        $display("");
        $write("y=%x", y);
        $display(" (lowercase)");
        pass_count++;

        // Test 3: Binary format %b
        $display("\n--- Test 3: Binary format ---");
        $write("vec=%b", vec);
        $display("");
        pass_count++;

        // Test 4: Octal format %o
        $display("\n--- Test 4: Octal format ---");
        $write("x=%o", x);
        $display("");
        pass_count++;

        // Test 5: String format %s
        $display("\n--- Test 5: String format ---");
        $write("s=%s", s);
        $display("");
        pass_count++;

        // Test 6: Multiple format specifiers
        $display("\n--- Test 6: Multiple format specifiers ---");
        $write("x=%0d, y=%h, s=%s", x, y, s);
        $display("");
        pass_count++;

        // Test 7: Verify no newline behavior
        $display("\n--- Test 7: No newline verification ---");
        $write("ABC");
        $write("DEF");
        $write("GHI");
        $display("");  // Should print "ABCDEFGHI" on one line
        pass_count++;

        // Test 8: Width specifier
        $display("\n--- Test 8: Width specifier ---");
        $write("|%8d|", x);
        $display("");
        pass_count++;

        // Test 9: Negative numbers
        $display("\n--- Test 9: Negative numbers ---");
        $write("neg=%0d", neg);
        $display("");
        pass_count++;

        // Summary
        $display("\n=== Test Summary ===");
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);

        if (fail_count == 0) begin
            $display("PASS: All $write format tests passed");
        end else begin
            $display("FAIL: Some tests failed");
        end

        $finish;
    end
endmodule
