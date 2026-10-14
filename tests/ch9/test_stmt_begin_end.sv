/*
:name: test_stmt_begin_end
:description: Test for begin-end blocks
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_begin_end.expected
*/
// Test for begin-end blocks
// IEEE 1800-2023 §9.3.1: Sequential blocks
module test_stmt_begin_end;
    initial begin
        int a, b, c;

        // Simple begin-end
        begin
            a = 1;
            b = 2;
            c = a + b;
        end
        if (c != 3) $display("FAIL: Simple begin-end");

        // Named block
        begin : my_block
            int local_var;
            local_var = 10;
            a = local_var;
        end
        if (a != 10) $display("FAIL: Named block");

        // Nested blocks
        begin
            a = 0;
            begin
                a = a + 1;
                begin
                    a = a + 2;
                end
                a = a + 3;
            end
            a = a + 4;
        end
        if (a != 10) $display("FAIL: Nested blocks");

        // Empty block
        begin
        end

        $display("PASS: Begin-end blocks");
        $finish;
    end
endmodule
