/*
:name: test_type_casts
:description: Type casting
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.12.1 6.24.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_casts.expected
*/
// IEEE 1800-2023 Section 6.24: Type casting
module test_type_casts;
    real r;
    int i;
    logic [7:0] byte_val;
    logic [31:0] word;
    shortreal sr;

    initial begin
        // Integer to real
        i = 42;
        r = real'(i);
        if (r == 42.0)
            $display("PASS: int to real cast");
        else
            $display("FAIL: int to real, got %f", r);

        // Real to integer (truncation)
        r = 3.7;
        i = int'(r);
        if (i == 4)  // real to integer conversion rounds to nearest (6.12.1)
            $display("PASS: real to int cast (rounding)");
        else
            $display("FAIL: real to int, got %0d", i);

        // Bit width reduction
        word = 32'hABCD1234;
        byte_val = 8'(word);
        if (byte_val == 8'h34)
            $display("PASS: bit width reduction");
        else
            $display("FAIL: bit reduction, got 0x%h", byte_val);

        // Bit width extension
        byte_val = 8'hFF;
        word = 32'(byte_val);
        if (word == 32'h000000FF)
            $display("PASS: bit width extension");
        else
            $display("FAIL: bit extension, got 0x%h", word);

        // Signed/unsigned cast
        i = -1;
        word = $unsigned(i);
        if (word == 32'hFFFFFFFF)
            $display("PASS: signed to unsigned");
        else
            $display("FAIL: signed to unsigned, got 0x%h", word);

        $display("TEST PASSED: type cast tests completed");
        $finish;
    end
endmodule
