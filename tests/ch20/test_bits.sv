/*
:name: test_bits
:description: Bit/array query functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.2 20.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bits.expected
*/
// IEEE 1800-2023 Section 20.6: Bit/array query functions
module test_bits;
    logic [7:0] byte_val;
    logic [31:0] word_val;
    int arr [0:9];
    int result;

    initial begin
        // $bits
        result = $bits(byte_val);
        if (result == 8)
            $display("PASS: $bits byte");
        else
            $display("FAIL: bits byte = %0d", result);

        result = $bits(word_val);
        if (result == 32)
            $display("PASS: $bits word");
        else
            $display("FAIL: bits word = %0d", result);

        // $size
        result = $size(arr);
        if (result == 10)
            $display("PASS: $size array");
        else
            $display("FAIL: size = %0d", result);

        // $left, $right
        result = $left(arr);
        if (result == 0)
            $display("PASS: $left");
        else
            $display("FAIL: left = %0d", result);

        result = $right(arr);
        if (result == 9)
            $display("PASS: $right");
        else
            $display("FAIL: right = %0d", result);

        $display("TEST PASSED: bit query tests completed");
        $finish;
    end
endmodule
