/*
:name: test_stmt_disable
:description: Test for disable statement
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_disable.expected
*/
// Test for disable statement
// IEEE 1800-2023 §9.6.2: Disable statement
module test_stmt_disable;
    initial begin
        int count;

        // Disable named block
        count = 0;
        begin : outer
            count++;
            begin : inner
                count++;
                if (count >= 2) disable inner;
                count++;
            end
            count++;
        end
        if (count != 3) $display("FAIL: Disable inner %0d", count);

        // Disable outer block
        count = 0;
        begin : loop_block
            for (int i = 0; i < 100; i++) begin
                count++;
                if (count >= 5) disable loop_block;
            end
            count = 999;  // Should not reach here
        end
        if (count != 5) $display("FAIL: Disable outer %0d", count);

        $display("PASS: Disable statement");
        $finish;
    end
endmodule
