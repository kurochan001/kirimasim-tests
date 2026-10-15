/*
:name: test_string_compare
:description: String comparison operators: ==, !=, <, >, <=, >=
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_compare.expected
*/
// String comparison operators: ==, !=, <, >, <=, >=
module test_string_compare;
    string s1, s2, s3;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: String equality
        s1 = "apple";
        s2 = "apple";
        if (s1 == s2) begin
            $display("PASS: Test 1 - String equality (==)");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - String equality (==)");
            fail_count++;
        end

        // Test 2: String inequality
        s1 = "apple";
        s2 = "orange";
        if (s1 != s2) begin
            $display("PASS: Test 2 - String inequality (!=)");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - String inequality (!=)");
            fail_count++;
        end

        // Test 3: String less than
        s1 = "apple";
        s2 = "banana";
        if (s1 < s2) begin
            $display("PASS: Test 3 - String less than (<)");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - String less than (<)");
            fail_count++;
        end

        // Test 4: String greater than
        s1 = "zebra";
        s2 = "apple";
        if (s1 > s2) begin
            $display("PASS: Test 4 - String greater than (>)");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - String greater than (>)");
            fail_count++;
        end

        // Test 5: String less than or equal
        s1 = "apple";
        s2 = "apple";
        s3 = "banana";
        if (s1 <= s2 && s1 <= s3) begin
            $display("PASS: Test 5 - String less than or equal (<=)");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - String less than or equal (<=)");
            fail_count++;
        end

        // Test 6: String greater than or equal
        s1 = "zebra";
        s2 = "zebra";
        s3 = "apple";
        if (s1 >= s2 && s1 >= s3) begin
            $display("PASS: Test 6 - String greater than or equal (>=)");
            pass_count++;
        end else begin
            $display("FAIL: Test 6 - String greater than or equal (>=)");
            fail_count++;
        end

        $display("\nSummary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
