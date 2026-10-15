/*
:name: test_equality
:description: Equality operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.5 11.4.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_equality.expected
*/
// IEEE 1800-2023 Section 11.4.5: Equality operators
module test_equality;
    logic [3:0] a, b;
    logic result;

    initial begin
        // Logical equality
        a = 4'b1010;
        b = 4'b1010;
        result = (a == b);
        if (result == 1)
            $display("PASS: 1010 == 1010");
        else
            $display("FAIL: == = %b", result);

        // Logical inequality
        b = 4'b1011;
        result = (a != b);
        if (result == 1)
            $display("PASS: 1010 != 1011");
        else
            $display("FAIL: != = %b", result);

        // Case equality (includes X/Z)
        a = 4'b10x0;
        b = 4'b10x0;
        result = (a === b);
        if (result == 1)
            $display("PASS: 10x0 === 10x0");
        else
            $display("FAIL: === = %b", result);

        // Case inequality
        a = 4'b10x0;
        b = 4'b10z0;
        result = (a !== b);
        if (result == 1)
            $display("PASS: 10x0 !== 10z0");
        else
            $display("FAIL: !== = %b", result);

        // Wildcard equality
        a = 4'b1010;
        b = 4'b10?0;
        result = (a ==? b);
        if (result == 1)
            $display("PASS: 1010 ==? 10?0");
        else
            $display("FAIL: ==? = %b", result);

        $display("TEST PASSED: equality tests completed");
        $finish;
    end
endmodule
