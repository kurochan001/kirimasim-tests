/*
:name: test_string_putc_2
:description: Test: String putc method
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_putc_2.expected
*/
// Test: String putc method
module test_string_putc_2;
    string s;
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: Modify first character
        s = "hello";
        s.putc(0, "H");
        if (s == "Hello") begin
            $display("Test 1 PASS: modify first char");
            passed++;
        end else begin
            $display("Test 1 FAIL: modify first char, got %s", s);
            failed++;
        end

        // Test 2: Modify last character
        s = "hello";
        s.putc(4, "O");
        if (s == "hellO") begin
            $display("Test 2 PASS: modify last char");
            passed++;
        end else begin
            $display("Test 2 FAIL: modify last char, got %s", s);
            failed++;
        end

        // Test 3: Modify middle character
        s = "hello";
        s.putc(2, "L");
        if (s == "heLlo") begin
            $display("Test 3 PASS: modify middle char");
            passed++;
        end else begin
            $display("Test 3 FAIL: modify middle char, got %s", s);
            failed++;
        end

        // Test 4: Multiple modifications
        s = "test";
        s.putc(0, "T");
        s.putc(3, "T");
        if (s == "TesT") begin
            $display("Test 4 PASS: multiple modifications");
            passed++;
        end else begin
            $display("Test 4 FAIL: multiple modifications, got %s", s);
            failed++;
        end

        // Test 5: Replace with number character
        s = "abc";
        s.putc(1, "2");
        if (s == "a2c") begin
            $display("Test 5 PASS: replace with number");
            passed++;
        end else begin
            $display("Test 5 FAIL: replace with number, got %s", s);
            failed++;
        end

        if (failed == 0)
            $display("PASS: All %0d tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
