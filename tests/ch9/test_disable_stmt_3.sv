/*
:name: test_disable_stmt_3
:description: disable of named blocks, nested blocks and blocks containing loops
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_stmt_3.expected
*/
// disable of named blocks, nested blocks and blocks containing loops

module test_disable_stmt;
    int pass_count = 0;
    int total_tests = 8;

    // Test variables
    int count;
    int sum;
    int i, j;

    initial begin
        // Test 1: Disable named block
        count = 0;
        begin : block1
            count++;
            count++;
            disable block1;
            count = 100;  // Should not execute
        end
        if (count == 2) pass_count++;

        // Test 2: Disable in nested block
        count = 0;
        begin : outer_block
            count++;
            begin
                count++;
                disable outer_block;
                count = 100;
            end
            count = 200;  // Should not execute
        end
        if (count == 2) pass_count++;

        // Test 3: Disable loop block
        sum = 0;
        begin : loop_block
            for (i = 0; i < 10; i++) begin
                sum += i;
                if (sum >= 10) disable loop_block;
            end
        end
        if (sum == 10) pass_count++;  // 0+1+2+3+4

        // Test 4: Disable specific inner block
        count = 0;
        begin : outer
            count++;
            begin : inner
                count++;
                disable inner;
                count = 100;  // Should not execute
            end
            count++;  // Should execute
        end
        if (count == 3) pass_count++;

        // Test 5: Conditional disable
        count = 0;
        begin : cond_block
            for (i = 0; i < 10; i++) begin
                count++;
                if (i == 5) begin
                    disable cond_block;
                end
            end
        end
        if (count == 6) pass_count++;  // 0,1,2,3,4,5 = 6 iterations

        // Test 6: Disable in nested loops
        sum = 0;
        begin : nested_loop
            for (i = 0; i < 5; i++) begin
                for (j = 0; j < 5; j++) begin
                    sum++;
                    if (sum >= 10) disable nested_loop;
                end
            end
        end
        if (sum == 10) pass_count++;

        // Test 7: Multiple named blocks
        count = 0;
        begin : blockA
            count++;
        end
        begin : blockB
            count++;
            begin : blockB_inner
                count++;
                disable blockB_inner;
                count = 100;
            end
            count++;  // Should execute
        end
        if (count == 4) pass_count++;

        // Test 8: Disable with complex condition
        sum = 0;
        count = 0;
        begin : complex_block
            forever begin
                sum += count;
                count++;
                if (count >= 10) disable complex_block;
            end
        end
        if (sum == 45) pass_count++;  // 0+1+2+...+9 = 45

        $display("PASS: disable_stmt (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
