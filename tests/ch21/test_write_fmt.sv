/*
:name: test_write_fmt
:description: $write Format Tests
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_write_fmt.expected
*/
// IEEE 1800-2023 Section 21.2 - $write Format Tests
module test_write_fmt;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int val;
        string s;

        $display("=== IEEE 1800-2023 $write Format Tests ===");

        // All tests based on $write executing without error
        
        // Test 1: Simple write
        $display("Test 1: Simple write");
        val = 123;
        $write("Value: %0d", val);
        $write("\n");
        pass_count++;
        $display("Test 1 PASS");

        // Test 2: No newline chain
        $display("Test 2: No newline chain");
        $write("A");
        $write("B");
        $write("C");
        $write("\n");
        pass_count++;
        $display("Test 2 PASS");

        // Test 3: Mixed with display
        $display("Test 3: Mixed with display");
        $write("Start ");
        $display("End");
        pass_count++;
        $display("Test 3 PASS");

        // Test 4: Counter
        $display("Test 4: Counter");
        for (int i = 0; i < 5; i++) $write("%0d ", i);
        $write("\n");
        pass_count++;
        $display("Test 4 PASS");

        // Test 5: String write
        $display("Test 5: String write");
        s = "hello";
        $write("%s world\n", s);
        pass_count++;
        $display("Test 5 PASS");

        // Test 6: Hex write
        $display("Test 6: Hex write");
        val = 255;
        $write("Hex: %h\n", val);
        pass_count++;
        $display("Test 6 PASS");

        // Test 7: Empty write
        $display("Test 7: Empty write");
        $write("");
        pass_count++;
        $display("Test 7 PASS");

        // Test 8: Multiple values
        $display("Test 8: Multiple values");
        $write("%0d %0d %0d\n", 1, 2, 3);
        pass_count++;
        $display("Test 8 PASS");

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
