/*
:name: test_stmt_disable_2
:description: Disable statement test
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_disable_2.expected
*/
// Disable statement test
module test_disable;
    int result;
    int pass_count = 0;
    event done_event;

    initial begin
        // Scenario 1: Disable named block
        result = 0;
        begin : block1
            result = 1;
            disable block1;
            result = 2;  // Never executed
        end
        if (result == 1) pass_count++;
        else $display("FAIL: Disable named block result=%0d", result);

        // Scenario 2: Disable nested block
        result = 0;
        begin : outer
            result = 10;
            begin : inner
                result = 20;
                disable inner;
                result = 30;  // Never executed
            end
            result = result + 1;  // Should execute: 20+1=21
        end
        if (result == 21) pass_count++;
        else $display("FAIL: Disable nested block result=%0d", result);

        // Scenario 3: Disable outer block from inner
        result = 0;
        begin : outer2
            result = 100;
            begin : inner2
                result = 200;
                disable outer2;
                result = 300;  // Never executed
            end
            result = 400;  // Never executed
        end
        if (result == 200) pass_count++;
        else $display("FAIL: Disable outer block from inner result=%0d", result);

        // Scenario 4: Disable in loop
        result = 0;
        begin : loop_block
            for (int i = 0; i < 10; i++) begin
                result = result + 1;
                if (i == 4) disable loop_block;
            end
            result = 999;  // Never executed
        end
        if (result == 5) pass_count++;  // i=0,1,2,3,4 then disable
        else $display("FAIL: Disable in loop result=%0d", result);

        // Scenario 5: Conditional disable
        result = 0;
        begin : cond_block
            for (int i = 0; i < 5; i++) begin
                result = result + i;
                if (result > 5) disable cond_block;
            end
        end
        if (result == 6) pass_count++;  // 0+1+2+3=6 > 5, then disable
        else $display("FAIL: Conditional disable result=%0d", result);

        if (pass_count == 5) $display("PASS");
        else $display("FAIL: pass_count=%0d", pass_count);
        $finish;
    end
endmodule
