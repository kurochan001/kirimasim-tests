/*
:name: test_logical
:description: Logical operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_logical.expected
*/
// IEEE 1800-2023 Section 11.4.7: Logical operators
module test_logical;
    logic a, b, result;
    int x, y;

    initial begin
        // Logical AND
        a = 1; b = 1;
        result = a && b;
        if (result == 1)
            $display("PASS: 1 && 1 = 1");
        else
            $display("FAIL: && result = %b", result);

        a = 1; b = 0;
        result = a && b;
        if (result == 0)
            $display("PASS: 1 && 0 = 0");
        else
            $display("FAIL: && result = %b", result);

        // Logical OR
        a = 0; b = 0;
        result = a || b;
        if (result == 0)
            $display("PASS: 0 || 0 = 0");
        else
            $display("FAIL: || result = %b", result);

        a = 0; b = 1;
        result = a || b;
        if (result == 1)
            $display("PASS: 0 || 1 = 1");
        else
            $display("FAIL: || result = %b", result);

        // Logical NOT
        a = 0;
        result = !a;
        if (result == 1)
            $display("PASS: !0 = 1");
        else
            $display("FAIL: ! result = %b", result);

        // Integer logical
        x = 5; y = 0;
        result = x && y;
        if (result == 0)
            $display("PASS: 5 && 0 = 0");
        else
            $display("FAIL: int && = %b", result);

        $display("TEST PASSED: logical tests completed");
        $finish;
    end
endmodule
