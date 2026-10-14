/*
:name: test_expr_compare
:description: Test for comparison operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.5
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_expr_compare.expected
*/
// Test for comparison operators
// IEEE 1800-2023 §11.4.5: Equality and relational operators
module test_expr_compare;
    initial begin
        static int a = 10, b = 20;
        static logic [3:0] x = 4'b1010;
        static logic [3:0] y = 4'b10x0;

        // Relational
        if (!(a < b)) $display("FAIL: Less than");
        if (!(b > a)) $display("FAIL: Greater than");
        if (!(a <= a)) $display("FAIL: Less or equal");
        if (!(b >= b)) $display("FAIL: Greater or equal");

        // Equality
        if (a == b) $display("FAIL: Equal");
        if (!(a != b)) $display("FAIL: Not equal");

        // Case equality
        if (x === y) $display("FAIL: Case equal with x");
        if (!(x !== y)) $display("FAIL: Case not equal");

        // Wildcard equality
        if (!(x ==? y)) $display("FAIL: Wildcard equal");

        $display("PASS: Comparison operators");
        $finish;
    end
endmodule
