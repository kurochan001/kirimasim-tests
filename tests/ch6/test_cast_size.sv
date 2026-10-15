/*
:name: test_cast_size
:description: Test for size casts
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_size.expected
*/
// Test for size casts
// IEEE 1800-2023 §6.24.1: Size casting
module test_cast_size;
    initial begin
        logic [7:0] a;
        logic [15:0] b;
        logic [31:0] c;
        logic [3:0] d;

        // Extend
        a = 8'hAB;
        b = 16'(a);
        if (b != 16'h00AB) $display("FAIL: extend 8 to 16");

        c = 32'(a);
        if (c != 32'h0000_00AB) $display("FAIL: extend 8 to 32");

        // Truncate
        c = 32'hDEAD_BEEF;
        a = 8'(c);
        if (a != 8'hEF) $display("FAIL: truncate 32 to 8");

        d = 4'(c);
        if (d != 4'hF) $display("FAIL: truncate 32 to 4");

        // Same size
        a = 8'h12;
        a = 8'(a);
        if (a != 8'h12) $display("FAIL: same size");

        $display("PASS: Size casts");
        $finish;
    end
endmodule
