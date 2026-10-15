/*
:name: test_value_packed
:description: Test for packed value operations
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_value_packed.expected
*/
// Test for packed value operations
// IEEE 1800-2023 §7.4.1: Packed arrays
module test_value_packed;
    typedef struct packed {
        logic [7:0] high;
        logic [7:0] low;
    } word_t;

    initial begin
        word_t w1, w2;
        logic [15:0] raw;

        // Packed struct as bits
        w1.high = 8'hAB;
        w1.low = 8'hCD;
        raw = w1;
        if (raw != 16'hABCD) $display("FAIL: Packed to raw %h", raw);

        // Raw to packed
        raw = 16'h1234;
        w2 = raw;
        if (w2.high != 8'h12) $display("FAIL: Raw to packed high");
        if (w2.low != 8'h34) $display("FAIL: Raw to packed low");

        // Bit operations on packed
        w1 = w1 | 16'h00F0;
        if (w1 != 16'hABFD) $display("FAIL: Packed OR %h", w1);

        // Part select on packed
        w1 = 16'hDEAD;
        if (w1[15:8] != 8'hDE) $display("FAIL: Part select high");
        if (w1[7:0] != 8'hAD) $display("FAIL: Part select low");

        $display("PASS: Packed value operations");
        $finish;
    end
endmodule
