/*
:name: test_initial_edge_cases
:description: Initial block edge cases
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_initial_edge_cases.expected
*/
// IEEE 1800-2023 §9.2.1: Initial block edge cases
// Tests for initial blocks

module test_initial_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int a, b, c;
    logic [7:0] data;

    // First initial block
    initial begin
        a = 10;
    end

    // Second initial block
    initial begin
        b = 20;
    end

    // Third initial block
    initial begin
        c = 30;
    end

    // Main test initial block
    initial begin
        #1;  // Wait for other initials

        // Test 1: All initial blocks ran
        test_count++;
        if (a == 10 && b == 20 && c == 30) begin
            pass_count++;
            $display("Test 1 PASS: All initials ran a=%0d b=%0d c=%0d", a, b, c);
        end else begin
            $display("Test 1 FAIL: Initials unexpected");
        end

        // Test 2: Initial with delay
        test_count++;
        data = 8'h00;
        #5;
        data = 8'hAA;
        if (data == 8'hAA) begin
            pass_count++;
            $display("Test 2 PASS: Delay data = %h", data);
        end else begin
            $display("Test 2 FAIL: Delay unexpected");
        end

        // Test 3: Multiple assignments
        test_count++;
        a = 1;
        a = 2;
        a = 3;
        if (a == 3) begin
            pass_count++;
            $display("Test 3 PASS: Multi assign a = %0d", a);
        end else begin
            $display("Test 3 FAIL: Multi unexpected");
        end

        // Test 4: Local in initial
        test_count++;
        begin
            static int local_init = 100;
            if (local_init == 100) begin
                pass_count++;
                $display("Test 4 PASS: Local in initial = %0d", local_init);
            end else begin
                $display("Test 4 FAIL: Local unexpected");
            end
        end

        // Test 5: Loop in initial
        test_count++;
        begin
            static int sum = 0;
            for (int i = 0; i < 5; i++) sum += i;
            if (sum == 10) begin
                pass_count++;
                $display("Test 5 PASS: Loop sum = %0d", sum);
            end else begin
                $display("Test 5 FAIL: Loop unexpected");
            end
        end

        // Test 6: Conditional in initial
        test_count++;
        begin
            static int x = 5;
            int result;
            if (x > 3) result = 1;
            else result = 0;
            if (result == 1) begin
                pass_count++;
                $display("Test 6 PASS: Conditional = %0d", result);
            end else begin
                $display("Test 6 FAIL: Cond unexpected");
            end
        end

        // Test 7: Array in initial
        test_count++;
        begin
            static int arr[4] = '{1, 2, 3, 4};
            if (arr[0] == 1 && arr[3] == 4) begin
                pass_count++;
                $display("Test 7 PASS: Array init");
            end else begin
                $display("Test 7 FAIL: Array unexpected");
            end
        end

        // Test 8: Nested blocks
        test_count++;
        begin : outer
            static int x = 1;
            begin : inner
                static int y = 2;
                if (x + y == 3) begin
                    pass_count++;
                    $display("Test 8 PASS: Nested = %0d", x + y);
                end else begin
                    $display("Test 8 FAIL: Nested unexpected");
                end
            end
        end

        // Test 9: Zero delay
        test_count++;
        a = 0;
        #0;
        a = 1;
        if (a == 1) begin
            pass_count++;
            $display("Test 9 PASS: Zero delay");
        end else begin
            $display("Test 9 FAIL: Zero unexpected");
        end

        $display("=== Initial Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
