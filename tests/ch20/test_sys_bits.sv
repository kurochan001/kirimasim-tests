/*
:name: test_sys_bits
:description: Test for $bits and related
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.2 20.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sys_bits.expected
*/
// Test for $bits and related
// IEEE 1800-2023 §20.6.2 and §20.7: $bits and array query functions
module test_sys_bits;
    typedef struct packed {
        logic [7:0] a;
        logic [15:0] b;
    } data_t;

    initial begin
        int result;
        logic [31:0] vec;
        int arr[10];
        data_t d;

        // $bits of vector
        result = $bits(vec);
        if (result != 32) $display("FAIL: bits of vec32");

        // $bits of int
        result = $bits(result);
        if (result != 32) $display("FAIL: bits of int");

        // $bits of struct
        result = $bits(d);
        if (result != 24) $display("FAIL: bits of struct");

        // $size
        result = $size(arr);
        if (result != 10) $display("FAIL: size of arr");

        // $left/$right
        result = $left(vec);
        if (result != 31) $display("FAIL: left");

        result = $right(vec);
        if (result != 0) $display("FAIL: right");

        // $high/$low
        result = $high(arr);
        if (result != 9) $display("FAIL: high");

        result = $low(arr);
        if (result != 0) $display("FAIL: low");

        $display("PASS: Bits and size functions");
        $finish;
    end
endmodule
