/*
:name: test_string_ops_3
:description: String operation edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16 5.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_ops_3.expected
*/
// String operation edge cases
module test_string_ops_3;
    int pass_count = 0;
    int total_tests = 15;

    // Test variables
    string s1, s2, s3, result;
    int int_val;
    byte char_val;

    initial begin
        // Test 1: Empty string
        s1 = "";
        if (s1.len() == 0) begin
            $display("PASS: Empty string length is 0");
            pass_count++;
        end else begin
            $display("FAIL: Empty string length: expected 0, got %0d", s1.len());
        end

        // Test 2: String concatenation
        s1 = "Hello";
        s2 = " World";
        s3 = {s1, s2};
        if (s3 == "Hello World") begin
            $display("PASS: String concatenation");
            pass_count++;
        end else begin
            $display("FAIL: Concatenation: expected 'Hello World', got '%s'", s3);
        end

        // Test 3: String comparison equal
        s1 = "test";
        s2 = "test";
        if (s1 == s2) begin
            $display("PASS: String equality comparison");
            pass_count++;
        end else begin
            $display("FAIL: String equality failed");
        end

        // Test 4: String comparison not equal
        s1 = "abc";
        s2 = "abd";
        if (s1 != s2) begin
            $display("PASS: String inequality comparison");
            pass_count++;
        end else begin
            $display("FAIL: String inequality failed");
        end

        // Test 5: String length
        s1 = "Hello, World!";
        if (s1.len() == 13) begin
            $display("PASS: String length");
            pass_count++;
        end else begin
            $display("FAIL: String length: expected 13, got %0d", s1.len());
        end

        // Test 6: Get character at index
        s1 = "ABCDE";
        char_val = s1.getc(2);
        if (char_val == "C") begin
            $display("PASS: getc() at index 2");
            pass_count++;
        end else begin
            $display("FAIL: getc(2): expected 'C', got '%c'", char_val);
        end

        // Test 7: String to upper
        s1 = "hello";
        result = s1.toupper();
        if (result == "HELLO") begin
            $display("PASS: toupper()");
            pass_count++;
        end else begin
            $display("FAIL: toupper: expected 'HELLO', got '%s'", result);
        end

        // Test 8: String to lower
        s1 = "WORLD";
        result = s1.tolower();
        if (result == "world") begin
            $display("PASS: tolower()");
            pass_count++;
        end else begin
            $display("FAIL: tolower: expected 'world', got '%s'", result);
        end

        // Test 9: putc - modify character
        s1 = "Hello";
        s1.putc(0, "J");
        if (s1 == "Jello") begin
            $display("PASS: putc() modify first char");
            pass_count++;
        end else begin
            $display("FAIL: putc: expected 'Jello', got '%s'", s1);
        end

        // Test 10: substr
        s1 = "Hello World";
        result = s1.substr(0, 4);
        if (result == "Hello") begin
            $display("PASS: substr(0,4)");
            pass_count++;
        end else begin
            $display("FAIL: substr: expected 'Hello', got '%s'", result);
        end

        // Test 11: atoi - string to integer
        s1 = "12345";
        int_val = s1.atoi();
        if (int_val == 12345) begin
            $display("PASS: atoi()");
            pass_count++;
        end else begin
            $display("FAIL: atoi: expected 12345, got %0d", int_val);
        end

        // Test 12: String with special characters
        s1 = "Line1\nLine2";
        if (s1.len() == 11) begin
            $display("PASS: String with newline character");
            pass_count++;
        end else begin
            $display("FAIL: Special char length: expected 11, got %0d", s1.len());
        end

        // Test 13: String with escape sequences
        s1 = "Tab\there";
        if (s1.len() == 8) begin
            $display("PASS: String with tab character");
            pass_count++;
        end else begin
            $display("FAIL: Tab string length: expected 8, got %0d", s1.len());
        end

        // Test 14: Empty concatenation
        s1 = "";
        s2 = "Test";
        s3 = {s1, s2};
        if (s3 == "Test") begin
            $display("PASS: Empty string concatenation");
            pass_count++;
        end else begin
            $display("FAIL: Empty concat: expected 'Test', got '%s'", s3);
        end

        // Test 15: String comparison less than
        s1 = "apple";
        s2 = "banana";
        if (s1 < s2) begin
            $display("PASS: String less than comparison");
            pass_count++;
        end else begin
            $display("FAIL: String less than failed");
        end

        if (pass_count == total_tests) $display("PASS: string_ops (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: string_ops (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
