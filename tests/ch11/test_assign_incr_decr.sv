/*
:name: test_assign_incr_decr
:description: Test for increment/decrement operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_incr_decr.expected
*/
// Test for increment/decrement operators
// IEEE 1800-2023 §11.4.2: Increment and decrement operators
module test_assign_incr_decr;
    initial begin
        static int a = 10;
        int b;

        // Pre-increment
        b = ++a;
        if (a != 11) $display("FAIL: Pre-inc a = %0d", a);
        if (b != 11) $display("FAIL: Pre-inc b = %0d", b);

        // Post-increment
        b = a++;
        if (a != 12) $display("FAIL: Post-inc a = %0d", a);
        if (b != 11) $display("FAIL: Post-inc b = %0d", b);

        // Pre-decrement
        b = --a;
        if (a != 11) $display("FAIL: Pre-dec a = %0d", a);
        if (b != 11) $display("FAIL: Pre-dec b = %0d", b);

        // Post-decrement
        b = a--;
        if (a != 10) $display("FAIL: Post-dec a = %0d", a);
        if (b != 11) $display("FAIL: Post-dec b = %0d", b);

        // In expressions
        a = 5;
        // Two increments of one variable in one expression have no defined
        // order (11.4.2), so they are split into two statements.
        b = a++;        // b = 5, a = 6
        b = b + ++a;    // a = 7, b = 5 + 7 = 12
        if (b != 12) $display("FAIL: Mixed expr b = %0d", b);

        $display("PASS: Increment/decrement");
        $finish;
    end
endmodule
