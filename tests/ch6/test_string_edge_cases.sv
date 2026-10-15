/*
:name: test_string_edge_cases
:description: String edge cases test
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_edge_cases.expected
*/
// IEEE 1800-2023: String edge cases test
// Tests various string-related edge cases

module test_string_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    string s1, s2, s3;

    initial begin
        // Test 1: Empty string length
        test_count++;
        s1 = "";
        if (s1.len() == 0) begin
            pass_count++;
            $display("Test 1 PASS: empty string length is 0");
        end else begin
            $display("Test 1 FAIL: empty string length issue");
        end

        // Test 2: Empty string comparison
        test_count++;
        s1 = "";
        s2 = "";
        if (s1 == s2) begin
            pass_count++;
            $display("Test 2 PASS: empty strings are equal");
        end else begin
            $display("Test 2 FAIL: empty string comparison issue");
        end

        // Test 3: String concatenation with empty
        test_count++;
        s1 = "hello";
        s2 = "";
        s3 = {s1, s2};
        if (s3 == "hello") begin
            pass_count++;
            $display("Test 3 PASS: concat with empty string");
        end else begin
            $display("Test 3 FAIL: concat issue");
        end

        // Test 4: toupper on empty
        test_count++;
        s1 = "";
        s2 = s1.toupper();
        if (s2 == "") begin
            pass_count++;
            $display("Test 4 PASS: toupper on empty");
        end else begin
            $display("Test 4 FAIL: toupper issue");
        end

        // Test 5: substr with zero length
        test_count++;
        s1 = "hello";
        s2 = s1.substr(0, 0);
        if (s2 == "h") begin
            pass_count++;
            $display("Test 5 PASS: substr with single char");
        end else begin
            $display("Test 5 FAIL: substr issue (got '%s')", s2);
        end

        // Test 6: String with spaces
        test_count++;
        s1 = "   ";
        if (s1.len() == 3) begin
            pass_count++;
            $display("Test 6 PASS: string with spaces");
        end else begin
            $display("Test 6 FAIL: space string issue");
        end

        // Test 7: getc at boundary
        test_count++;
        s1 = "abc";
        if (s1.getc(0) == "a" && s1.getc(2) == "c") begin
            pass_count++;
            $display("Test 7 PASS: getc at boundaries");
        end else begin
            $display("Test 7 FAIL: getc issue");
        end

        // Test 8: putc at boundary
        test_count++;
        s1 = "abc";
        s1.putc(0, "X");
        s1.putc(2, "Z");
        if (s1 == "XbZ") begin
            pass_count++;
            $display("Test 8 PASS: putc at boundaries");
        end else begin
            $display("Test 8 FAIL: putc issue (got '%s')", s1);
        end

        // Test 9: String with special characters
        test_count++;
        s1 = "tab\there\nnewline";
        if (s1.len() > 10) begin
            pass_count++;
            $display("Test 9 PASS: string with special chars");
        end else begin
            $display("Test 9 FAIL: special chars issue");
        end

        // Test 10: atoi edge cases
        test_count++;
        s1 = "0";
        s2 = "-0";
        if (s1.atoi() == 0 && s2.atoi() == 0) begin
            pass_count++;
            $display("Test 10 PASS: atoi zero cases");
        end else begin
            $display("Test 10 FAIL: atoi issue");
        end

        $display("=== String Edge Cases Test Results ===");
        $display("Passed: %0d/%0d", pass_count, test_count);

        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end

endmodule
