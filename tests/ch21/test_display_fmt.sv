/*
:name: test_display_fmt
:description: $display Format Tests
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_display_fmt.expected
*/
// IEEE 1800-2023 Section 21.2 - $display Format Tests
module test_display_fmt;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int a, b;
        string s;
        logic [15:0] lv;

        $display("=== IEEE 1800-2023 $display Format Tests ===");

        // All tests based on $display executing without error
        
        // Test 1: Simple int
        $display("Test 1: Simple int");
        a = 100;
        $display("Value: %0d", a);
        pass_count++;
        $display("Test 1 PASS");

        // Test 2: Multiple values
        $display("Test 2: Multiple values");
        a = 10; b = 20;
        $display("a=%0d b=%0d sum=%0d", a, b, a+b);
        pass_count++;
        $display("Test 2 PASS");

        // Test 3: Hex format
        $display("Test 3: Hex format");
        lv = 16'hABCD;
        $display("Hex: %h", lv);
        pass_count++;
        $display("Test 3 PASS");

        // Test 4: Binary format
        $display("Test 4: Binary format");
        lv = 16'b1010101010101010;
        $display("Binary: %b", lv);
        pass_count++;
        $display("Test 4 PASS");

        // Test 5: String
        $display("Test 5: String");
        s = "test_string";
        $display("String: %s", s);
        pass_count++;
        $display("Test 5 PASS");

        // Test 6: Mixed types
        $display("Test 6: Mixed types");
        a = 42;
        s = "answer";
        $display("The %s is %0d", s, a);
        pass_count++;
        $display("Test 6 PASS");

        // Test 7: No args
        $display("Test 7: No args");
        $display("No arguments");
        pass_count++;
        $display("Test 7 PASS");

        // Test 8: Expression
        $display("Test 8: Expression");
        a = 5;
        $display("5*5=%0d", a*a);
        pass_count++;
        $display("Test 8 PASS");

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
