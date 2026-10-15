/*
:name: test_string_getc
:description: Test: String getc method
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_getc.expected
*/
// Test: String getc method
// IEEE 1800-2023 Section 6.16.3

module test_string_getc;
    initial begin
        string s;
        byte c;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Get first character
        s = "Hello";
        c = s.getc(0);
        if (c == "H") begin
            $display("PASS: getc(0) returned 'H' (0x%0h)", c);
            pass_count++;
        end else begin
            $display("FAIL: getc(0) expected 'H', got 0x%0h", c);
            fail_count++;
        end

        // Test 2: Get middle character
        c = s.getc(2);
        if (c == "l") begin
            $display("PASS: getc(2) returned 'l' (0x%0h)", c);
            pass_count++;
        end else begin
            $display("FAIL: getc(2) expected 'l', got 0x%0h", c);
            fail_count++;
        end

        // Test 3: Get last character
        c = s.getc(4);
        if (c == "o") begin
            $display("PASS: getc(4) returned 'o' (0x%0h)", c);
            pass_count++;
        end else begin
            $display("FAIL: getc(4) expected 'o', got 0x%0h", c);
            fail_count++;
        end

        // Test 4: Get character from numeric string
        s = "12345";
        c = s.getc(0);
        if (c == "1") begin
            $display("PASS: getc(0) from '12345' returned '1' (0x%0h)", c);
            pass_count++;
        end else begin
            $display("FAIL: getc(0) expected '1', got 0x%0h", c);
            fail_count++;
        end

        // Test 5: Get space character
        s = "A B";
        c = s.getc(1);
        if (c == " ") begin
            $display("PASS: getc(1) returned space (0x%0h)", c);
            pass_count++;
        end else begin
            $display("FAIL: getc(1) expected space, got 0x%0h", c);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All string getc tests passed");
        else
            $display("FAIL: Some string getc tests failed");

        $finish;
    end
endmodule
