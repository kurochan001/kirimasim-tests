/*
:name: test_sscanf_simple
:description: $sscanf reading integers, hex values, a string and a real
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_simple.expected
*/
// Simple test for the $sscanf system function
module test_sscanf_simple;

    initial begin
        string input_str;
        integer a, b;
        real f;
        string s;
        integer n;  // number of fields read

        $display("Testing $sscanf...");

        // Test integer parsing
        input_str = "42 100";
        n = $sscanf(input_str, "%d %d", a, b);
        if (n == 2 && a == 42 && b == 100)
            $display("PASS: Integer parsing");
        else
            $display("FAIL: Integer parsing - got a=%d, b=%d", a, b);

        // Test hex parsing
        input_str = "DEAD BEEF";
        n = $sscanf(input_str, "%h %h", a, b);
        if (n == 2 && a == 'hDEAD && b == 'hBEEF)
            $display("PASS: Hex parsing");
        else
            $display("FAIL: Hex parsing - got a=%h, b=%h", a, b);

        // Test string and float
        input_str = "Hello 3.14";
        n = $sscanf(input_str, "%s %f", s, f);
        if (n == 2 && s == "Hello" && f == 3.14)
            $display("PASS: String parsing");
        else
            $display("FAIL: String parsing - got s='%s', f=%f", s, f);

        $display("$sscanf test complete");
        $finish;
    end

endmodule
