/*
:name: test_stmt_casez
:description: Test for casez statements
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_stmt_casez.expected
*/
// Test for casez statements
// IEEE 1800-2023 §12.5.1: casez and casex
module test_stmt_casez;
    initial begin
        logic [3:0] val;
        int result;

        // casez with don't care
        val = 4'b1010;
        casez (val)
            4'b0???: result = 1;
            4'b10??: result = 2;
            4'b11??: result = 3;
            default: result = 0;
        endcase
        if (result != 2) $display("FAIL: casez pattern");

        // casez with z
        val = 4'b1z01;
        casez (val)
            4'b1?01: result = 10;
            default: result = 0;
        endcase
        if (result != 10) $display("FAIL: casez with z");

        // casex
        val = 4'bx101;
        casex (val)
            4'b?101: result = 20;
            default: result = 0;
        endcase
        if (result != 20) $display("FAIL: casex");

        $display("PASS: Casez statements");
        $finish;
    end
endmodule
