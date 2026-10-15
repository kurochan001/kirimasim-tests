/*
:name: test_local_var_scope
:description: Block, function and task local variables, static and automatic
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21 13.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_local_var_scope.expected
*/
// Block, function and task local variables, static and automatic
module test_local_var_scope;
    int pass_count = 0;
    int total_tests = 8;

    int module_var = 1000;

    function automatic int test_auto_local();
        int local_counter = 0;
        local_counter++;
        return local_counter;
    endfunction

    function int test_static_local();
        static int static_counter = 0;
        static_counter++;
        return static_counter;
    endfunction

    task automatic test_task_local(output int result);
        int task_local = 42;
        result = task_local;
    endtask

    initial begin
        static int outer_var = 100;

        // Test 1: Module scope variable
        if (module_var == 1000) begin
            $display("Test 1 PASS: module_var = %0d", module_var);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: module_var = %0d, expected 1000", module_var);
        end

        // Test 2: Block local variable
        begin
            static int block_var = 200;
            if (block_var == 200) begin
                $display("Test 2 PASS: block_var = %0d", block_var);
                pass_count++;
            end else begin
                $display("Test 2 FAIL: block_var = %0d, expected 200", block_var);
            end
        end

        // Test 3: Nested block scoping
        begin
            static int level1 = 10;
            begin
                static int level2 = 20;
                if (level1 == 10 && level2 == 20) begin
                    $display("Test 3 PASS: level1=%0d, level2=%0d", level1, level2);
                    pass_count++;
                end else begin
                    $display("Test 3 FAIL: level1=%0d, level2=%0d", level1, level2);
                end
            end
        end

        // Test 4: Automatic function local (resets each call)
        begin
            int r1, r2, r3;
            r1 = test_auto_local();
            r2 = test_auto_local();
            r3 = test_auto_local();
            if (r1 == 1 && r2 == 1 && r3 == 1) begin
                $display("Test 4 PASS: auto local resets each call");
                pass_count++;
            end else begin
                $display("Test 4 FAIL: r1=%0d, r2=%0d, r3=%0d", r1, r2, r3);
            end
        end

        // Test 5: Static function local (persists across calls)
        begin
            int r1, r2, r3;
            r1 = test_static_local();
            r2 = test_static_local();
            r3 = test_static_local();
            if (r1 == 1 && r2 == 2 && r3 == 3) begin
                $display("Test 5 PASS: static local persists: %0d, %0d, %0d", r1, r2, r3);
                pass_count++;
            end else begin
                $display("Test 5 FAIL: r1=%0d, r2=%0d, r3=%0d", r1, r2, r3);
            end
        end

        // Test 6: For loop variable scope
        begin
            static int sum = 0;
            for (int i = 0; i < 5; i++) begin
                sum += i;
            end
            if (sum == 10) begin  // 0+1+2+3+4 = 10
                $display("Test 6 PASS: for loop sum = %0d", sum);
                pass_count++;
            end else begin
                $display("Test 6 FAIL: sum = %0d, expected 10", sum);
            end
        end

        // Test 7: Task local variable
        begin
            int task_result;
            test_task_local(task_result);
            if (task_result == 42) begin
                $display("Test 7 PASS: task_result = %0d", task_result);
                pass_count++;
            end else begin
                $display("Test 7 FAIL: task_result = %0d, expected 42", task_result);
            end
        end

        // Test 8: Shadowing (inner hides outer)
        begin
            static int shadow = 500;
            begin
                static int shadow = 600;  // Shadows outer
                if (shadow == 600) begin
                    $display("Test 8 PASS: inner shadow = %0d", shadow);
                    pass_count++;
                end else begin
                    $display("Test 8 FAIL: inner shadow = %0d, expected 600", shadow);
                end
            end
        end

        $display("PASS: local_var_scope (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
