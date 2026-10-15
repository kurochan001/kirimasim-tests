/*
:name: test_edge_case_strings
:description: Corner case tests for string operations
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_edge_case_strings.expected
*/
// Corner case tests for string operations
module test_edge_case_strings;
    int errors = 0;
    string s1, s2, s3;
    int result;

    initial begin
        // Test 1: Empty string operations
        s1 = "";
        if (s1.len() !== 0) begin
            $display("FAIL: Empty string len should be 0");
            errors++;
        end

        // Test 2: Empty string comparison
        s2 = "";
        if (s1 != s2) begin
            $display("FAIL: Two empty strings should be equal");
            errors++;
        end

        // Test 3: Concatenation with empty
        s1 = "";
        s2 = "hello";
        s3 = {s1, s2};
        if (s3 != "hello") begin
            $display("FAIL: Empty + 'hello' should be 'hello'");
            errors++;
        end
        s3 = {s2, s1};
        if (s3 != "hello") begin
            $display("FAIL: 'hello' + empty should be 'hello'");
            errors++;
        end

        // Test 4: Single character string
        s1 = "a";
        if (s1.len() !== 1) begin
            $display("FAIL: Single char string len should be 1");
            errors++;
        end
        if (s1.getc(0) !== 8'd97) begin  // 'a' = 97
            $display("FAIL: getc(0) should be 97");
            errors++;
        end

        // Test 5: String comparison (lexicographic)
        if (!("abc" < "abd")) begin
            $display("FAIL: 'abc' should be less than 'abd'");
            errors++;
        end
        if (!("ab" < "abc")) begin
            $display("FAIL: 'ab' should be less than 'abc'");
            errors++;
        end

        // Test 6: String toupper/tolower
        s1 = "HeLLo WoRLd";
        if (s1.toupper() != "HELLO WORLD") begin
            $display("FAIL: toupper should return 'HELLO WORLD'");
            errors++;
        end
        if (s1.tolower() != "hello world") begin
            $display("FAIL: tolower should return 'hello world'");
            errors++;
        end

        // Test 7: String with special characters
        s1 = "hello\tworld\n";
        if (s1.len() !== 12) begin
            $display("FAIL: String with \\t and \\n should have len 12");
            errors++;
        end

        // Test 8: String substr edge cases
        s1 = "abcdefgh";
        if (s1.substr(0, 0) != "a") begin
            $display("FAIL: substr(0,0) should be 'a'");
            errors++;
        end
        if (s1.substr(7, 7) != "h") begin
            $display("FAIL: substr(7,7) should be 'h'");
            errors++;
        end
        if (s1.substr(0, 7) != "abcdefgh") begin
            $display("FAIL: substr(0,7) should be full string");
            errors++;
        end

        // Test 9: String replication
        s1 = "ab";
        s2 = {3{s1}};
        if (s2 != "ababab") begin
            $display("FAIL: {3{'ab'}} should be 'ababab'");
            errors++;
        end

        // Test 10: String to integer conversion
        s1 = "12345";
        result = s1.atoi();
        if (result !== 12345) begin
            $display("FAIL: '12345'.atoi() should be 12345");
            errors++;
        end

        // Test 11: String with leading/trailing spaces
        s1 = "  test  ";
        if (s1.len() !== 8) begin
            $display("FAIL: String with spaces should preserve them");
            errors++;
        end

        // Test 12: itoa conversion
        s1.itoa(255);
        if (s1 != "255") begin
            $display("FAIL: itoa(255) should be '255', got '%s'", s1);
            errors++;
        end
        s1.itoa(-1);
        if (s1 != "-1") begin
            $display("FAIL: itoa(-1) should be '-1', got '%s'", s1);
            errors++;
        end

        // Test 13: hextoa conversion
        s1.hextoa(255);
        if (s1 != "ff") begin
            $display("FAIL: hextoa(255) should be 'ff', got '%s'", s1);
            errors++;
        end

        if (errors == 0) begin
            $display("TEST PASSED: String edge case tests passed");
        end else begin
            $display("TEST FAILED: %0d errors", errors);
        end
        $finish;
    end
endmodule
