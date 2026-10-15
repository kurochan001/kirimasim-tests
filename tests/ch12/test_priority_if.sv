/*
:name: test_priority_if
:description: Test: priority if statement
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_priority_if.expected
*/
// Test: priority if statement

module test_priority_if;
    logic [1:0] sel;
    int result;

    initial begin
        sel = 2'b11;

        priority if (sel[0])
            result = 1;
        else if (sel[1])
            result = 2;
        else
            result = 0;

        if (result == 1) begin  // First matching condition wins
            $display("PASS: priority if");
        end else begin
            $display("FAIL: priority if");
        end
        $finish;
    end
endmodule
