/*
:name: test_local_var_edge_cases
:description: Local variable edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_local_var_edge_cases.expected
*/
// IEEE 1800-2023 §6: Local variable edge cases
// Tests for local variable declarations and scope

module test_local_var_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int global_var = 100;

    function int local_func(int x);
        static int local_in_func = 50;
        return x + local_in_func;
    endfunction

    initial begin
        // Test 1: Module level variable
        test_count++;
        if (global_var == 100) begin
            pass_count++;
            $display("Test 1 PASS: global_var = %0d", global_var);
        end else begin
            $display("Test 1 FAIL: Global unexpected = %0d", global_var);
        end

        // Test 2: Local in begin block
        test_count++;
        begin
            static int block_local = 200;
            if (block_local == 200) begin
                pass_count++;
                $display("Test 2 PASS: block_local = %0d", block_local);
            end else begin
                $display("Test 2 FAIL: Block unexpected = %0d", block_local);
            end
        end

        // Test 3: Local in nested block
        test_count++;
        begin
            static int outer_local = 10;
            begin
                static int inner_local = 20;
                if (outer_local + inner_local == 30) begin
                    pass_count++;
                    $display("Test 3 PASS: nested sum = %0d", outer_local + inner_local);
                end else begin
                    $display("Test 3 FAIL: Nested unexpected");
                end
            end
        end

        // Test 4: Local in function
        test_count++;
        begin
            int result;
            // Called here, not in a static initializer: local_in_func might not be
            // initialized yet when static initializers run (6.21).
            result = local_func(10);
            if (result == 60) begin
                pass_count++;
                $display("Test 4 PASS: function result = %0d", result);
            end else begin
                $display("Test 4 FAIL: Function unexpected = %0d", result);
            end
        end

        // Test 5: For loop index
        test_count++;
        begin
            static int sum = 0;
            for (int i = 0; i < 5; i++) sum += i;
            if (sum == 10) begin
                pass_count++;
                $display("Test 5 PASS: for sum = %0d", sum);
            end else begin
                $display("Test 5 FAIL: For unexpected = %0d", sum);
            end
        end

        // Test 6: Local shadowing
        test_count++;
        begin
            static int global_var = 999;  // Shadows module level
            if (global_var == 999) begin
                pass_count++;
                $display("Test 6 PASS: shadowed = %0d", global_var);
            end else begin
                $display("Test 6 FAIL: Shadow unexpected = %0d", global_var);
            end
        end

        // Test 7: Original after shadow block
        test_count++;
        if (global_var == 100) begin
            pass_count++;
            $display("Test 7 PASS: Original restored = %0d", global_var);
        end else begin
            $display("Test 7 FAIL: Restore unexpected = %0d", global_var);
        end

        // Test 8: Multiple declarations
        test_count++;
        begin
            static int a = 1, b = 2, c = 3;
            if (a + b + c == 6) begin
                pass_count++;
                $display("Test 8 PASS: Multi decl sum = %0d", a + b + c);
            end else begin
                $display("Test 8 FAIL: Multi unexpected");
            end
        end

        // Test 9: Array local
        test_count++;
        begin
            static int local_arr[4] = '{1, 2, 3, 4};
            static int sum = 0;
            foreach (local_arr[i]) sum += local_arr[i];
            if (sum == 10) begin
                pass_count++;
                $display("Test 9 PASS: local array sum = %0d", sum);
            end else begin
                $display("Test 9 FAIL: Array unexpected = %0d", sum);
            end
        end

        // Test 10: Logic type local
        test_count++;
        begin
            static logic [7:0] local_logic = 8'hAB;
            if (local_logic == 8'hAB) begin
                pass_count++;
                $display("Test 10 PASS: local logic = %h", local_logic);
            end else begin
                $display("Test 10 FAIL: Logic unexpected = %h", local_logic);
            end
        end

        // Test 11: String local
        test_count++;
        begin
            static string local_str = "test";
            if (local_str == "test") begin
                pass_count++;
                $display("Test 11 PASS: local string = %s", local_str);
            end else begin
                $display("Test 11 FAIL: String unexpected");
            end
        end

        // Test 12: Real type local
        test_count++;
        begin
            static real local_real = 3.14;
            if (local_real > 3.0 && local_real < 3.2) begin
                pass_count++;
                $display("Test 12 PASS: local real = %f", local_real);
            end else begin
                $display("Test 12 FAIL: Real unexpected");
            end
        end

        $display("=== Local Var Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
