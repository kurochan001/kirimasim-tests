/*
:name: test_relational
:description: Relational operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_relational.expected
*/
// IEEE 1800-2023 Section 11.4.4: Relational operators
module test_relational;
    int a, b;
    logic [7:0] x, y;
    logic result;

    initial begin
        a = 10; b = 20;

        // Less than
        result = (a < b);
        if (result == 1)
            $display("PASS: 10 < 20");
        else
            $display("FAIL: 10 < 20 = %b", result);

        // Greater than
        result = (a > b);
        if (result == 0)
            $display("PASS: 10 > 20 = false");
        else
            $display("FAIL: 10 > 20 = %b", result);

        // Less than or equal
        a = 20;
        result = (a <= b);
        if (result == 1)
            $display("PASS: 20 <= 20");
        else
            $display("FAIL: 20 <= 20 = %b", result);

        // Greater than or equal
        result = (a >= b);
        if (result == 1)
            $display("PASS: 20 >= 20");
        else
            $display("FAIL: 20 >= 20 = %b", result);

        // With unsigned
        x = 8'hFF;
        y = 8'h00;
        result = (x > y);
        if (result == 1)
            $display("PASS: 0xFF > 0x00 (unsigned)");
        else
            $display("FAIL: unsigned compare = %b", result);

        $display("TEST PASSED: relational tests completed");
        $finish;
    end
endmodule
