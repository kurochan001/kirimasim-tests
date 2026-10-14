/*
:name: test_sscanf
:description: String scanning
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf.expected
*/
// IEEE 1800-2023 Section 21.3.4: String scanning
module test_sscanf;
    string s;
    int a, b;
    int result;

    initial begin
        // Basic sscanf
        s = "42";
        result = $sscanf(s, "%d", a);
        if (result == 1 && a == 42)
            $display("PASS: sscanf basic");
        else
            $display("FAIL: basic a=%0d r=%0d", a, result);

        // Multiple values
        s = "10 20";
        result = $sscanf(s, "%d %d", a, b);
        if (result == 2 && a == 10 && b == 20)
            $display("PASS: sscanf multi");
        else
            $display("FAIL: multi a=%0d b=%0d r=%0d", a, b, result);

        // Hex format
        s = "AB";
        result = $sscanf(s, "%h", a);
        if (result == 1 && a == 171)
            $display("PASS: sscanf hex");
        else
            $display("FAIL: hex a=%0d r=%0d", a, result);

        $display("TEST PASSED: sscanf tests completed");
        $finish;
    end
endmodule
