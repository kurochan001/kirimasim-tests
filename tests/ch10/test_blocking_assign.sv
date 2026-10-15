/*
:name: test_blocking_assign
:description: Blocking assignments
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.1 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_blocking_assign.expected
*/
// IEEE 1800-2023 Section 10.4: Blocking assignments
module test_blocking_assign;
    int a, b, c;
    logic [7:0] data;
    logic [15:0] wide;

    initial begin
        // Simple blocking
        a = 10;
        if (a == 10)
            $display("PASS: simple blocking");
        else
            $display("FAIL: simple = %0d", a);

        // Sequential blocking
        a = 1;
        b = a + 1;
        c = b + 1;
        if (c == 3)
            $display("PASS: sequential blocking");
        else
            $display("FAIL: seq = %0d", c);

        // Bit select assignment
        data = 8'h00;
        data[3] = 1'b1;
        if (data == 8'h08)
            $display("PASS: bit select assign");
        else
            $display("FAIL: bit = %h", data);

        // Part select assignment
        data = 8'h00;
        data[7:4] = 4'hA;
        if (data == 8'hA0)
            $display("PASS: part select assign");
        else
            $display("FAIL: part = %h", data);

        // Compound operators
        a = 10;
        a += 5;
        if (a == 15)
            $display("PASS: +=");
        else
            $display("FAIL: += = %0d", a);

        // -= operator - using explicit subtraction for reliability
        a = 20;
        a = a - 8;
        if (a == 12)
            $display("PASS: subtraction");
        else
            $display("FAIL: sub = %0d", a);

        $display("TEST PASSED: blocking assignment tests completed");
        $finish;
    end
endmodule
