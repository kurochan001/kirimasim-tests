/*
:name: test_inside_expr_3
:description: Test: inside operator
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inside_expr_3.expected
*/
// Test: inside operator

module test_inside_expr_3;
    int pass_count = 0;
    int total_tests = 25;

    // Test variables
    int val;
    logic [7:0] byte_val;
    logic [3:0] nibble;
    string str_val;

    initial begin
        // Test 1: inside with single value - match
        val = 5;
        if (val inside {5}) begin
            $display("Test 1 PASSED: 5 inside {5}");
            pass_count++;
        end else $display("Test 1 FAILED");

        // Test 2: inside with single value - no match
        val = 5;
        if (!(val inside {6})) begin
            $display("Test 2 PASSED: 5 not inside {6}");
            pass_count++;
        end else $display("Test 2 FAILED");

        // Test 3: inside with multiple values - match
        val = 3;
        if (val inside {1, 2, 3, 4, 5}) begin
            $display("Test 3 PASSED: 3 inside {1,2,3,4,5}");
            pass_count++;
        end else $display("Test 3 FAILED");

        // Test 4: inside with multiple values - no match
        val = 10;
        if (!(val inside {1, 2, 3, 4, 5})) begin
            $display("Test 4 PASSED: 10 not inside {1,2,3,4,5}");
            pass_count++;
        end else $display("Test 4 FAILED");

        // Test 5: inside with range - match
        val = 15;
        if (val inside {[10:20]}) begin
            $display("Test 5 PASSED: 15 inside {[10:20]}");
            pass_count++;
        end else $display("Test 5 FAILED");

        // Test 6: inside with range - lower bound
        val = 10;
        if (val inside {[10:20]}) begin
            $display("Test 6 PASSED: 10 inside {[10:20]}");
            pass_count++;
        end else $display("Test 6 FAILED");

        // Test 7: inside with range - upper bound
        val = 20;
        if (val inside {[10:20]}) begin
            $display("Test 7 PASSED: 20 inside {[10:20]}");
            pass_count++;
        end else $display("Test 7 FAILED");

        // Test 8: inside with range - below
        val = 5;
        if (!(val inside {[10:20]})) begin
            $display("Test 8 PASSED: 5 not inside {[10:20]}");
            pass_count++;
        end else $display("Test 8 FAILED");

        // Test 9: inside with range - above
        val = 25;
        if (!(val inside {[10:20]})) begin
            $display("Test 9 PASSED: 25 not inside {[10:20]}");
            pass_count++;
        end else $display("Test 9 FAILED");

        // Test 10: inside with mixed values and ranges
        val = 50;
        if (val inside {1, 2, [10:20], 50, [100:200]}) begin
            $display("Test 10 PASSED: 50 inside mixed set");
            pass_count++;
        end else $display("Test 10 FAILED");

        // Test 11: inside with mixed - match range
        val = 15;
        if (val inside {1, 2, [10:20], 50, [100:200]}) begin
            $display("Test 11 PASSED: 15 inside mixed set (range)");
            pass_count++;
        end else $display("Test 11 FAILED");

        // Test 12: inside with zero
        val = 0;
        if (val inside {0, 1, 2}) begin
            $display("Test 12 PASSED: 0 inside {0,1,2}");
            pass_count++;
        end else $display("Test 12 FAILED");

        // Test 13: inside with negative values
        val = -5;
        if (val inside {-10, -5, 0, 5, 10}) begin
            $display("Test 13 PASSED: -5 inside negative set");
            pass_count++;
        end else $display("Test 13 FAILED");

        // Test 14: inside with negative range
        val = -3;
        if (val inside {[-5:-1]}) begin
            $display("Test 14 PASSED: -3 inside {[-5:-1]}");
            pass_count++;
        end else $display("Test 14 FAILED");

        // Test 15: inside with logic value
        byte_val = 8'hAB;
        if (byte_val inside {8'hAA, 8'hAB, 8'hAC}) begin
            $display("Test 15 PASSED: 0xAB inside logic set");
            pass_count++;
        end else $display("Test 15 FAILED");

        // Test 16: inside with nibble
        nibble = 4'hF;
        if (nibble inside {4'h0, 4'hF}) begin
            $display("Test 16 PASSED: 0xF inside nibble set");
            pass_count++;
        end else $display("Test 16 FAILED");

        // Test 17: value in the gap between two ranges
        val = 5;
        if (!(val inside {[0:4], [6:10]})) begin
            $display("Test 17 PASSED: 5 not inside {[0:4], [6:10]}");
            pass_count++;
        end else $display("Test 17 FAILED");

        // Test 18: inside with single range full match
        byte_val = 8'h80;
        if (byte_val inside {[8'h00:8'hFF]}) begin
            $display("Test 18 PASSED: 0x80 inside full byte range");
            pass_count++;
        end else $display("Test 18 FAILED");

        // Test 19: inside with overlapping ranges
        val = 15;
        if (val inside {[0:20], [10:30]}) begin
            $display("Test 19 PASSED: 15 inside overlapping ranges");
            pass_count++;
        end else $display("Test 19 FAILED");

        // Test 20: inside with expressions
        begin
            static int base = 10;
            val = 15;
            if (val inside {[base:base+10]}) begin
                $display("Test 20 PASSED: inside with expressions");
                pass_count++;
            end else $display("Test 20 FAILED");
        end

        // Test 21: inside in conditional
        val = 3;
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = val inside {1,2,3} ? 100 : 200;
            if (result == 100) begin
                $display("Test 21 PASSED: inside in conditional");
                pass_count++;
            end else $display("Test 21 FAILED");
        end

        // Test 22: inside with variable values
        begin
            static int a = 5, b = 10, c = 15;
            val = 10;
            if (val inside {a, b, c}) begin
                $display("Test 22 PASSED: inside with variables");
                pass_count++;
            end else $display("Test 22 FAILED");
        end

        // Test 23: inside negation
        val = 100;
        if (!(val inside {1, 2, 3})) begin
            $display("Test 23 PASSED: not inside");
            pass_count++;
        end else $display("Test 23 FAILED");

        // Test 24: inside with single point range
        val = 42;
        if (val inside {[42:42]}) begin
            $display("Test 24 PASSED: inside single point range");
            pass_count++;
        end else $display("Test 24 FAILED");

        // Test 25: inside complex expression
        byte_val = 8'h55;
        if (byte_val inside {8'h00, [8'h40:8'h60], 8'hFF}) begin
            $display("Test 25 PASSED: 0x55 inside complex set");
            pass_count++;
        end else $display("Test 25 FAILED");

        if (pass_count == total_tests) $display("PASS: inside_expr (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: inside_expr (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
