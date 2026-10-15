/*
:name: test_value_signed
:description: Arithmetic, comparison and arithmetic shift on signed 8-bit values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.8.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_value_signed.expected
*/
// Arithmetic, comparison and arithmetic shift on signed 8-bit values
// IEEE 1800-2023 §11.8: Signed expressions
module test_value_signed;
    initial begin
        logic signed [7:0] a, b, c;
        logic [7:0] u;

        // Signed arithmetic
        a = -10;
        b = 3;
        c = a + b;
        if (c != -7) $display("FAIL: Signed add %0d", c);

        c = a * b;
        if (c != -30) $display("FAIL: Signed mul %0d", c);

        c = a / b;
        if (c != -3) $display("FAIL: Signed div %0d", c);

        // Signed comparison
        a = -5;
        b = 5;
        if (a >= b) $display("FAIL: Signed compare");

        // Sign extension
        a = 8'hF0;  // -16 as signed
        c = a >>> 2;  // Arithmetic shift
        if (c != 8'hFC) $display("FAIL: Sign extend %h", c);

        // Cast to unsigned
        a = -1;
        u = unsigned'(a);
        if (u != 8'hFF) $display("FAIL: Cast unsigned %h", u);

        $display("PASS: Signed value operations");
        $finish;
    end
endmodule
