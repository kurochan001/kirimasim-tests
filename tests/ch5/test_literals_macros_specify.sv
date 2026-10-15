/*
:name: test_literals_macros_specify
:description: Based literals, underscores, real and string literals, macros and a specparam
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.1 22.5.1 5.12 6.20.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_literals_macros_specify.expected
*/
`timescale 1ns/1ps

// Based literals, underscores, real and string literals, macros and a specparam
`define MACRO_VAL 100
`define MACRO_FUNC(x) ((x) * 2)

module test_literals_macros_specify;
    // Different number formats
    int bin_val = 8'b10101010;
    int oct_val = 8'o252;
    int hex_val = 8'hAA;
    int dec_val = 170;

    // Underscores in numbers
    int underscore_val = 32'h1234_5678;

    // Real numbers
    real r1 = 1.5;
    real r2 = 1.5e3;
    real r3 = 1.5e-3;

    // Strings with escapes
    string s1 = "Hello\nWorld";
    string s2 = "Tab\tHere";
    string s3 = "Quote\"Test";

    // Attributes
    (* mark = "test" *)
    logic attr_signal;

    // Specify block
    specify
        specparam delay = 1.5;
    endspecify

    initial begin
        // Test parsed values
        if (bin_val != 170) $display("FAIL: bin");
        if (oct_val != 170) $display("FAIL: oct");
        if (hex_val != 170) $display("FAIL: hex");
        if (dec_val != 170) $display("FAIL: dec");
        if (underscore_val != 32'h12345678) $display("FAIL: underscore");

        // Test macros
        if (`MACRO_VAL != 100) $display("FAIL: macro");
        if (`MACRO_FUNC(5) != 10) $display("FAIL: macro func");

        $display("TEST PASSED");
        $finish;
    end
endmodule
