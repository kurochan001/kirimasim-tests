/*
:name: test_value_logic
:description: Test for logic value operations
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.3.1 11.4.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_value_logic.expected
*/
// Test for logic value operations
// IEEE 1800-2023 §6.3.1: Logic values
module test_value_logic;
    initial begin
        logic [7:0] a, b, c;
        logic x;

        // Basic logic values
        a = 8'b10101010;
        b = 8'b11110000;

        // AND
        c = a & b;
        if (c != 8'b10100000) $display("FAIL: AND");

        // OR
        c = a | b;
        if (c != 8'b11111010) $display("FAIL: OR");

        // XOR
        c = a ^ b;
        if (c != 8'b01011010) $display("FAIL: XOR");

        // NOT
        c = ~a;
        if (c != 8'b01010101) $display("FAIL: NOT");

        // X and Z handling
        x = 1'bx;
        if (x === 1'bx) $display("OK: X value");
        else $display("FAIL: X value");

        x = 1'bz;
        if (x === 1'bz) $display("OK: Z value");
        else $display("FAIL: Z value");

        $display("PASS: Logic value operations");
        $finish;
    end
endmodule
