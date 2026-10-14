/*
:name: test_assign_continuous
:description: Test for continuous assignment
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_continuous.expected
*/
// Test for continuous assignment
// IEEE 1800-2023 §10.3: Continuous assignments
module test_assign_continuous;
    logic a, b, c;
    logic [7:0] x, y, z;

    // Simple continuous assign
    assign c = a & b;

    // Expression continuous assign
    assign z = x + y;

    initial begin
        // Test simple
        a = 1'b0;
        b = 1'b0;
        #1;
        if (c != 1'b0) $display("FAIL: 0&0 = %b", c);

        a = 1'b1;
        b = 1'b1;
        #1;
        if (c != 1'b1) $display("FAIL: 1&1 = %b", c);

        a = 1'b1;
        b = 1'b0;
        #1;
        if (c != 1'b0) $display("FAIL: 1&0 = %b", c);

        // Test expression
        x = 8'h10;
        y = 8'h20;
        #1;
        if (z != 8'h30) $display("FAIL: x+y = %h", z);

        x = 8'hFF;
        y = 8'h01;
        #1;
        if (z != 8'h00) $display("FAIL: overflow = %h", z);

        $display("PASS: Continuous assignment");
        $finish;
    end
endmodule
