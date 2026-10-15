/*
:name: test_stmt_case
:description: Test for case statements
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_case.expected
*/
// Test for case statements
// IEEE 1800-2023 §12.5: Case statement
module test_stmt_case;
    initial begin
        int sel;
        int result;

        // Simple case
        sel = 2;
        case (sel)
            0: result = 10;
            1: result = 20;
            2: result = 30;
            default: result = 0;
        endcase
        if (result != 30) $display("FAIL: Simple case");

        // Default case
        sel = 99;
        case (sel)
            0: result = 10;
            1: result = 20;
            default: result = 99;
        endcase
        if (result != 99) $display("FAIL: Default case");

        // Multiple values
        sel = 3;
        case (sel)
            0, 1: result = 1;
            2, 3: result = 2;
            default: result = 0;
        endcase
        if (result != 2) $display("FAIL: Multiple values");

        $display("PASS: Case statements");
        $finish;
    end
endmodule
