/*
:name: test_realtime_ops_2
:description: Realtime variable operations
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_realtime_ops_2.expected
*/
// Realtime variable operations
module test_realtime_ops;
    realtime rt1, rt2, rt3;
    real r1;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Basic realtime assignment
        rt1 = 10.5;
        if (rt1 == 10.5) begin
            $display("PASS: Test 1 - Basic realtime assignment");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Basic realtime assignment, got %f", rt1);
            fail_count++;
        end

        // Test 2: Realtime arithmetic
        rt1 = 5.25;
        rt2 = 3.75;
        rt3 = rt1 + rt2;
        if (rt3 == 9.0) begin
            $display("PASS: Test 2 - Realtime addition");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Realtime addition, got %f", rt3);
            fail_count++;
        end

        // Test 3: Realtime multiplication
        rt1 = 2.5;
        rt2 = 4.0;
        rt3 = rt1 * rt2;
        if (rt3 == 10.0) begin
            $display("PASS: Test 3 - Realtime multiplication");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Realtime multiplication, got %f", rt3);
            fail_count++;
        end

        // Test 4: Realtime to real conversion
        rt1 = 123.456;
        r1 = rt1;
        if (r1 == 123.456) begin
            $display("PASS: Test 4 - Realtime to real conversion");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Realtime to real conversion, got %f", r1);
            fail_count++;
        end

        // Test 5: Realtime comparison
        rt1 = 100.0;
        rt2 = 50.0;
        if (rt1 > rt2) begin
            $display("PASS: Test 5 - Realtime comparison");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Realtime comparison");
            fail_count++;
        end

        $display("\nSummary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
