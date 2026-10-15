/*
:name: test_string_methods
:description: String methods
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16 6.16.1 6.16.3 6.16.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_methods.expected
*/
// IEEE 1800-2023 Section 6.16: String methods
module test_string_methods;
    string s, s2;
    int result;

    int fails = 0;


    initial begin
        s = "Hello World";

        // len()
        if (s.len() == 11)
            $display("PASS: len() = 11");
        else
            begin fails++; $display("FAIL: len() = %0d", s.len()); end

        // toupper()
        s2 = s.toupper();
        if (s2 == "HELLO WORLD")
            $display("PASS: toupper()");
        else
            begin fails++; $display("FAIL: toupper() = %s", s2); end

        // tolower()
        s2 = s.tolower();
        if (s2 == "hello world")
            $display("PASS: tolower()");
        else
            begin fails++; $display("FAIL: tolower() = %s", s2); end

        // substr()
        s2 = s.substr(0, 4);
        if (s2 == "Hello")
            $display("PASS: substr(0,4)");
        else
            begin fails++; $display("FAIL: substr() = %s", s2); end

        // getc()
        result = s.getc(0);
        if (result == 8'h48)  // 'H'
            $display("PASS: getc(0) = 'H'");
        else
            begin fails++; $display("FAIL: getc(0) = %0d", result); end

        // putc()
        s.putc(0, 8'h68);  // 'h'
        if (s == "hello World")
            $display("PASS: putc(0, 'h')");
        else
            begin fails++; $display("FAIL: putc result = %s", s); end

        if (fails == 0) $display("TEST PASSED: string methods tests completed");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
