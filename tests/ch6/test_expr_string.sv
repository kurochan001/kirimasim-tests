/*
:name: test_expr_string
:description: String expressions test
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16 11.4.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_string.expected
*/
// String expressions test
module test_expr_string;
    int pass_count = 0;
    int fail_count = 0;

    string s1, s2, s3;
    int len;

    initial begin
        // Test 1: String assignment and comparison
        s1 = "Hello";
        if (s1 == "Hello") begin
            $display("PASS: String assignment and comparison");
            pass_count++;
        end else begin
            $display("FAIL: String comparison failed");
            fail_count++;
        end

        // Test 2: String concatenation
        s1 = "Hello";
        s2 = " World";
        s3 = {s1, s2};
        if (s3 == "Hello World") begin
            $display("PASS: String concatenation");
            pass_count++;
        end else begin
            $display("FAIL: String concat, expected 'Hello World', got '%s'", s3);
            fail_count++;
        end

        // Test 3: String length
        s1 = "Test";
        len = s1.len();
        if (len == 4) begin
            $display("PASS: String length of 'Test' = 4");
            pass_count++;
        end else begin
            $display("FAIL: String length, expected 4, got %0d", len);
            fail_count++;
        end

        // Test 4: String methods (toupper, tolower)
        s1 = "Hello";
        s2 = s1.toupper();
        s3 = s1.tolower();
        if (s2 == "HELLO" && s3 == "hello") begin
            $display("PASS: toupper='HELLO', tolower='hello'");
            pass_count++;
        end else begin
            $display("FAIL: case conversion, got upper='%s' lower='%s'", s2, s3);
            fail_count++;
        end

        // Test 5: String getc (character access)
        s1 = "ABCD";
        if (s1.getc(0) == "A" && s1.getc(3) == "D") begin
            $display("PASS: getc(0)='A', getc(3)='D'");
            pass_count++;
        end else begin
            $display("FAIL: getc failed");
            fail_count++;
        end

        // Summary
        $display("String expressions: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All string expression tests passed");
        else $display("FAIL: Some string expression tests failed");
        $finish;
    end
endmodule
