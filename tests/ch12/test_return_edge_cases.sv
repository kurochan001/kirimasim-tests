/*
:name: test_return_edge_cases
:description: Return statement edge cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.8 13.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_return_edge_cases.expected
*/
// IEEE 1800-2023 §12.8 and §13.4.1: Return statement edge cases
// Tests for return in functions

module test_return_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    function int simple_return(int x);
        return x * 2;
    endfunction

    function int early_return(int x);
        if (x < 0) return -1;
        if (x == 0) return 0;
        return x + 10;
    endfunction

    function int nested_return(int x);
        if (x > 0) begin
            if (x > 10) begin
                return 100;
            end
            return 50;
        end
        return 0;
    endfunction

    function int loop_return(int n);
        for (int i = 0; i < n; i++) begin
            if (i == 5) return i;
        end
        return -1;
    endfunction

    function automatic int recursive_sum(int n);
        if (n <= 0) return 0;
        return n + recursive_sum(n - 1);
    endfunction

    initial begin
        // Test 1: Simple return
        test_count++;
        if (simple_return(5) == 10) begin
            pass_count++;
            $display("Test 1 PASS: Simple = %0d", simple_return(5));
        end else begin
            $display("Test 1 FAIL: Simple unexpected");
        end

        // Test 2: Early return negative
        test_count++;
        if (early_return(-5) == -1) begin
            pass_count++;
            $display("Test 2 PASS: Early neg = %0d", early_return(-5));
        end else begin
            $display("Test 2 FAIL: Early unexpected");
        end

        // Test 3: Early return zero
        test_count++;
        if (early_return(0) == 0) begin
            pass_count++;
            $display("Test 3 PASS: Early zero = %0d", early_return(0));
        end else begin
            $display("Test 3 FAIL: Zero unexpected");
        end

        // Test 4: Normal return
        test_count++;
        if (early_return(5) == 15) begin
            pass_count++;
            $display("Test 4 PASS: Normal = %0d", early_return(5));
        end else begin
            $display("Test 4 FAIL: Normal unexpected");
        end

        // Test 5: Nested deep return
        test_count++;
        if (nested_return(20) == 100) begin
            pass_count++;
            $display("Test 5 PASS: Deep = %0d", nested_return(20));
        end else begin
            $display("Test 5 FAIL: Deep unexpected");
        end

        // Test 6: Nested shallow return
        test_count++;
        if (nested_return(5) == 50) begin
            pass_count++;
            $display("Test 6 PASS: Shallow = %0d", nested_return(5));
        end else begin
            $display("Test 6 FAIL: Shallow unexpected");
        end

        // Test 7: Loop return found
        test_count++;
        if (loop_return(10) == 5) begin
            pass_count++;
            $display("Test 7 PASS: Loop found = %0d", loop_return(10));
        end else begin
            $display("Test 7 FAIL: Loop unexpected");
        end

        // Test 8: Loop return not found
        test_count++;
        if (loop_return(3) == -1) begin
            pass_count++;
            $display("Test 8 PASS: Not found = %0d", loop_return(3));
        end else begin
            $display("Test 8 FAIL: Notfound unexpected");
        end

        // Test 9: Recursive return
        test_count++;
        if (recursive_sum(5) == 15) begin
            pass_count++;
            $display("Test 9 PASS: Recursive = %0d", recursive_sum(5));
        end else begin
            $display("Test 9 FAIL: Recursive unexpected");
        end

        // Test 10: Return expression
        test_count++;
        begin
            static int val = simple_return(simple_return(2));
            if (val == 8) begin
                pass_count++;
                $display("Test 10 PASS: Nested call = %0d", val);
            end else begin
                $display("Test 10 FAIL: Nested unexpected");
            end
        end

        $display("=== Return Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
