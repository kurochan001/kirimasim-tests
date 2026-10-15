/*
:name: test_string_methods_2
:description: String Methods (§6.16)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_methods_2.expected
*/
// IEEE 1800-2023 String Methods (§6.16)
// Tests string methods: len, getc, toupper, tolower, compare, substr

module test_string_methods_2;
    initial begin
        string s1, s2, s3;
        int result;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: len
        s1 = "Hello";
        if (s1.len() == 5) begin
            $display("PASS: len() = %0d", s1.len());
            pass_count++;
        end else begin
            $display("FAIL: len() = %0d, expected 5", s1.len());
            fail_count++;
        end

        // Test 2: getc
        if (s1.getc(0) == "H" && s1.getc(4) == "o") begin
            $display("PASS: getc() works correctly");
            pass_count++;
        end else begin
            $display("FAIL: getc() returned wrong characters");
            fail_count++;
        end

        // Test 3: toupper
        s2 = s1.toupper();
        if (s2 == "HELLO") begin
            $display("PASS: toupper() = %s", s2);
            pass_count++;
        end else begin
            $display("FAIL: toupper() = %s, expected HELLO", s2);
            fail_count++;
        end

        // Test 4: tolower
        s2 = "WORLD";
        s3 = s2.tolower();
        if (s3 == "world") begin
            $display("PASS: tolower() = %s", s3);
            pass_count++;
        end else begin
            $display("FAIL: tolower() = %s, expected world", s3);
            fail_count++;
        end

        // Test 5: compare
        s1 = "abc";
        s2 = "abd";
        result = s1.compare(s2);
        if (result < 0) begin
            $display("PASS: compare(abc, abd) < 0");
            pass_count++;
        end else begin
            $display("FAIL: compare(abc, abd) = %0d, expected < 0", result);
            fail_count++;
        end

        // Test 6: icompare (case insensitive)
        s1 = "ABC";
        s2 = "abc";
        result = s1.icompare(s2);
        if (result == 0) begin
            $display("PASS: icompare(ABC, abc) = 0");
            pass_count++;
        end else begin
            $display("FAIL: icompare(ABC, abc) = %0d, expected 0", result);
            fail_count++;
        end

        // Test 7: substr
        s1 = "Hello World";
        s2 = s1.substr(6, 10);
        if (s2 == "World") begin
            $display("PASS: substr(6, 10) = %s", s2);
            pass_count++;
        end else begin
            $display("FAIL: substr(6, 10) = %s, expected World", s2);
            fail_count++;
        end

        // Test 8: putc
        s1 = "Hello";
        s1.putc(0, "J");
        if (s1 == "Jello") begin
            $display("PASS: putc(0, J) = %s", s1);
            pass_count++;
        end else begin
            $display("FAIL: putc(0, J) = %s, expected Jello", s1);
            fail_count++;
        end

        $display("");
        $display("=== String Methods Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
