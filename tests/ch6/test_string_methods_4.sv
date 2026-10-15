/*
:name: test_string_methods_4
:description: Test string methods: len, substr, getc, putc, toupper, tolower
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_methods_4.expected
*/
// Test string methods: len, substr, getc, putc, toupper, tolower
module test_string_methods_4;
    string s1, s2, s3;
    int len_val;
    byte c;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: String len()
        s1 = "Hello";
        len_val = s1.len();
        if (len_val == 5) begin
            $display("PASS: Test 1 - String len() = %0d", len_val);
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - String len(), expected 5, got %0d", len_val);
            fail_count++;
        end

        // Test 2: String substr()
        s1 = "Hello World";
        s2 = s1.substr(0, 4);
        if (s2 == "Hello") begin
            $display("PASS: Test 2 - String substr(0,4) = '%s'", s2);
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - String substr(), expected 'Hello', got '%s'", s2);
            fail_count++;
        end

        // Test 3: String getc()
        s1 = "ABCDE";
        c = s1.getc(2);
        if (c == "C") begin
            $display("PASS: Test 3 - String getc(2) = '%c'", c);
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - String getc(2), expected 'C', got '%c'", c);
            fail_count++;
        end

        // Test 4: String putc()
        s1 = "Hello";
        s1.putc(0, "J");
        if (s1 == "Jello") begin
            $display("PASS: Test 4 - String putc() = '%s'", s1);
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - String putc(), expected 'Jello', got '%s'", s1);
            fail_count++;
        end

        // Test 5: String toupper()
        s1 = "hello";
        s2 = s1.toupper();
        if (s2 == "HELLO") begin
            $display("PASS: Test 5 - String toupper() = '%s'", s2);
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - String toupper(), expected 'HELLO', got '%s'", s2);
            fail_count++;
        end

        // Test 6: String tolower()
        s1 = "WORLD";
        s2 = s1.tolower();
        if (s2 == "world") begin
            $display("PASS: Test 6 - String tolower() = '%s'", s2);
            pass_count++;
        end else begin
            $display("FAIL: Test 6 - String tolower(), expected 'world', got '%s'", s2);
            fail_count++;
        end

        $display("\nSummary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
