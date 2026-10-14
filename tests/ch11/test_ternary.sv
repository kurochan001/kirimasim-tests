/*
:name: test_ternary
:description: Conditional operator
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11 21.2.1.3
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_ternary.expected
*/
// IEEE 1800-2023 Section 11.4.11: Conditional operator
module test_ternary;
    int a, b, result;
    logic cond;
    logic [7:0] x, y, z;

    initial begin
        a = 10;
        b = 20;

        // Basic ternary
        cond = 1;
        result = cond ? a : b;
        if (result == 10)
            $display("PASS: true ? a : b = a");
        else
            $display("FAIL: got %0d", result);

        cond = 0;
        result = cond ? a : b;
        if (result == 20)
            $display("PASS: false ? a : b = b");
        else
            $display("FAIL: got %0d", result);

        // Nested ternary
        a = 1; b = 2;
        result = (a > b) ? 100 : (a == b) ? 50 : 0;
        if (result == 0)
            $display("PASS: nested ternary");
        else
            $display("FAIL: nested = %0d", result);

        // Ternary with x value
        x = 8'hFF;
        y = 8'hAA;
        z = 1'bx ? x : y;  // Result should be x
        $display("INFO: x-condition result = 0x%h (may contain X)", z);

        $display("TEST PASSED: ternary tests completed");
        $finish;
    end
endmodule
