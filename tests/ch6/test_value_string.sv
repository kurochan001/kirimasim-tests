/*
:name: test_value_string
:description: Test for string value operations
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_value_string.expected
*/
// Test for string value operations
// IEEE 1800-2023 §6.16: String data type
module test_value_string;
    int fails = 0;

    initial begin
        string s1, s2, s3;
        int len;

        // String assignment
        s1 = "Hello";
        s2 = "World";

        // Concatenation
        s3 = {s1, " ", s2};
        if (s3 != "Hello World") begin fails++; $display("FAIL: Concat %s", s3); end

        // Length
        len = s1.len();
        if (len != 5) begin fails++; $display("FAIL: Length %0d", len); end

        // Comparison
        if (s1 == s2) begin fails++; $display("FAIL: Compare equal"); end
        if (s1 != "Hello") begin fails++; $display("FAIL: Compare not equal"); end

        // Substring
        s3 = s1.substr(1, 3);
        if (s3 != "ell") begin fails++; $display("FAIL: Substr %s", s3); end

        // Character access
        if (s1.getc(0) != "H") begin fails++; $display("FAIL: getc"); end

        // Upper/lower
        s3 = s1.toupper();
        if (s3 != "HELLO") begin fails++; $display("FAIL: toupper %s", s3); end

        s3 = s3.tolower();
        if (s3 != "hello") begin fails++; $display("FAIL: tolower %s", s3); end

        if (fails == 0) $display("PASS: String value operations");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
