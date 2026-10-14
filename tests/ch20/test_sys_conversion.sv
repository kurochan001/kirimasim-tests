/*
:name: test_sys_conversion
:description: Test for conversion system functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5 11.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sys_conversion.expected
*/
// Test for conversion system functions
// IEEE 1800-2023 §20.5: Conversion functions
module test_sys_conversion;
    initial begin
        int i;
        real r;
        logic [31:0] v;
        logic [63:0] v64;  // $realtobits returns 64 bits per IEEE 754

        // $itor
        i = 42;
        r = $itor(i);
        if (r != 42.0) $display("FAIL: itor");

        // $rtoi
        r = 3.7;
        i = $rtoi(r);
        if (i != 3) $display("FAIL: rtoi");

        // $realtobits / $bitstoreal (64-bit per IEEE 1800-2023 §20.5)
        r = 1.5;
        v64 = $realtobits(r);
        // Verify IEEE 754 representation of 1.5: 0x3FF8000000000000
        if (v64 != 64'h3FF8000000000000) $display("FAIL: realtobits");

        // $bitstoreal
        r = $bitstoreal(v64);
        if (r != 1.5) $display("FAIL: bitstoreal");

        // $signed
        v = 32'hFFFF_FFFF;
        i = $signed(v);
        if (i != -1) $display("FAIL: signed");

        // $unsigned
        i = -1;
        v = $unsigned(i);
        if (v != 32'hFFFF_FFFF) $display("FAIL: unsigned");

        $display("PASS: Conversion functions");
        $finish;
    end
endmodule
