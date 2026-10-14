/*
:name: test_cast_struct
:description: Test for struct casts
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2.1 6.24.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_struct.expected
*/
// Test for struct casts
// IEEE 1800-2023 §7.2.1: Packed struct casting
module test_cast_struct;
    typedef struct packed {
        logic [7:0] high;
        logic [7:0] low;
    } pair_t;

    initial begin
        pair_t p;
        logic [15:0] raw;
        logic [31:0] wide;

        // Raw to struct
        raw = 16'hABCD;
        p = pair_t'(raw);
        if (p.high != 8'hAB) $display("FAIL: raw to struct high");
        if (p.low != 8'hCD) $display("FAIL: raw to struct low");

        // Struct to raw
        p.high = 8'h12;
        p.low = 8'h34;
        raw = 16'(p);
        if (raw != 16'h1234) $display("FAIL: struct to raw");

        // Wider cast
        p.high = 8'hFF;
        p.low = 8'hEE;
        wide = 32'(p);
        if (wide != 32'h0000_FFEE) $display("FAIL: struct to wide");

        $display("PASS: Struct casts");
        $finish;
    end
endmodule
