/*
:name: test_expr_concat
:description: Test for concatenation expression
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_concat.expected
*/
// Test for concatenation expression
// IEEE 1800-2023 §11.4.12: Concatenation operators
module test_expr_concat;
    initial begin
        static logic [7:0] a = 8'hAB;
        static logic [7:0] b = 8'hCD;
        logic [15:0] c;
        logic [31:0] d;

        // Basic concat
        c = {a, b};
        if (c != 16'hABCD) $display("FAIL: Basic concat %h", c);

        // Replication
        d = {4{a}};
        if (d != 32'hABABABAB) $display("FAIL: Replication %h", d);

        // Mixed concat
        d = {a, {2{b}}, a};
        if (d != 32'hABCDCDAB) $display("FAIL: Mixed concat %h", d);

        $display("PASS: Concatenation expression");
        $finish;
    end
endmodule
