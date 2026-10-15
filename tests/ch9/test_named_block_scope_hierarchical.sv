/*
:name: test_named_block_scope_hierarchical
:description: Named block scope hierarchical access
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.4 23.6 6.21
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_named_block_scope_hierarchical.expected
*/
// IEEE 1800-2023 §9.3.5: Named block scope hierarchical access
// Tests that variables in named blocks can be accessed using hierarchical names
module test;
    // Test 1: Named block in initial block
    initial begin
        begin : outer_block
            static int x = 42;
            $display("In outer_block, x = %0d", x);
            begin : inner_block
                static int y = 100;
                $display("In inner_block, y = %0d", y);
                // Hierarchical access to variables in named blocks
                $display("Accessing outer_block.x = %0d", outer_block.x);
                $display("Accessing inner_block.y = %0d", inner_block.y);
                if (outer_block.x == 42 && inner_block.y == 100) begin
                    $display("PASS: Named block scope in initial block works");
                end else begin
                    $display("FAIL: Named block scope in initial block failed");
                    $fatal(1, "Test failed");
                end
            end
        end
    end

    // Test 2: Named block in task
    task test_named_block_in_task();
        begin : task_outer
            static int a = 10;
            begin : task_inner
                static int b = 20;
                if (task_outer.a == 10 && task_inner.b == 20) begin
                    $display("PASS: Named block scope in task works");
                end else begin
                    $display("FAIL: Named block scope in task failed");
                    $fatal(1, "Test failed");
                end
            end
        end
    endtask

    // Test 3: Named block in function
    function int test_named_block_in_function();
        begin : func_block
            static int result = 123;
            if (func_block.result == 123) begin
                $display("PASS: Named block scope in function works");
                return 1;
            end else begin
                $display("FAIL: Named block scope in function failed");
                return 0;
            end
        end
    endfunction

    initial begin
        #1;
        test_named_block_in_task();
        if (test_named_block_in_function() != 1) $fatal(1, "Function test failed");
        $display("TEST PASSED");
        $finish;
    end
endmodule
