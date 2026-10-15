/*
:name: test_operator_inside
:description: Inside operator test
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.13
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_inside.expected
*/
// Inside operator test
module test_operator_inside;
    int val;
    logic result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Value in set
        val = 5;
        result = val inside {1, 3, 5, 7, 9};
        if (result == 1'b1) begin
            $display("PASS: 5 inside {1,3,5,7,9} = 1");
            pass_count++;
        end else begin
            $display("FAIL: 5 inside {1,3,5,7,9}, expected 1, got %b", result);
            fail_count++;
        end

        // Test 2: Value not in set
        val = 4;
        result = val inside {1, 3, 5, 7, 9};
        if (result == 1'b0) begin
            $display("PASS: 4 inside {1,3,5,7,9} = 0");
            pass_count++;
        end else begin
            $display("FAIL: 4 inside {1,3,5,7,9}, expected 0, got %b", result);
            fail_count++;
        end

        // Test 3: Value in range
        val = 50;
        result = val inside {[10:100]};
        if (result == 1'b1) begin
            $display("PASS: 50 inside {[10:100]} = 1");
            pass_count++;
        end else begin
            $display("FAIL: 50 inside {[10:100]}, expected 1, got %b", result);
            fail_count++;
        end

        // Test 4: Value outside range
        val = 5;
        result = val inside {[10:100]};
        if (result == 1'b0) begin
            $display("PASS: 5 inside {[10:100]} = 0");
            pass_count++;
        end else begin
            $display("FAIL: 5 inside {[10:100]}, expected 0, got %b", result);
            fail_count++;
        end

        // Test 5: Mixed set and range
        val = 200;
        result = val inside {1, 5, [100:300], 500};
        if (result == 1'b1) begin
            $display("PASS: 200 inside {1, 5, [100:300], 500} = 1");
            pass_count++;
        end else begin
            $display("FAIL: Mixed set/range, expected 1, got %b", result);
            fail_count++;
        end

        // Summary
        $display("Inside operators: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All inside operator tests passed");
        else $display("FAIL: Some inside operator tests failed");
        $finish;
    end
endmodule
