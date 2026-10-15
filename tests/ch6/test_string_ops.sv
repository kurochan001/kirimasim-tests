/*
:name: test_string_ops
:description: Test for string operations
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16 11.4.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_ops.expected
*/
// Test for string operations
// IEEE 1800-2023 §6.16

module test_string_ops;
    string s1, s2, s3;
    int len;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: String assignment
        test_count++;
        s1 = "Hello";
        if (s1 == "Hello") begin
            $display("Test 1: String assignment PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: String concatenation
        test_count++;
        s2 = " World";
        s3 = {s1, s2};
        if (s3 == "Hello World") begin
            $display("Test 2: String concatenation PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: String length
        test_count++;
        len = s3.len();
        if (len == 11) begin
            $display("Test 3: String length PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL len=%0d", len);
        end

        // Test 4: String comparison
        test_count++;
        if (s1 < s3) begin
            $display("Test 4: String comparison PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: String to upper/lower
        test_count++;
        s1 = "hello";
        s2 = s1.toupper();
        if (s2 == "HELLO") begin
            $display("Test 5: String toupper PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
