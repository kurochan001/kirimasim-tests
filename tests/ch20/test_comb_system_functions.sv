/*
:name: test_comb_system_functions
:description: Test: System functions edge cases
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.1 20.9 6.21
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_comb_system_functions.expected
*/
// Test: System functions edge cases
// Verifies $clog2, $countones, $onehot, $onehot0, $isunknown
module test;
    int pass_count = 0;

    initial begin
        // Test 1: $clog2 basic
        begin
            static int val = $clog2(8);
            if (val == 3) begin
                $display("T1: PASS - $clog2(8) = %0d", val);
                pass_count++;
            end else begin
                $display("T1: FAIL - $clog2(8) = %0d (expected 3)", val);
            end
        end

        // Test 2: $clog2(1) = 0
        begin
            static int val = $clog2(1);
            if (val == 0) begin
                $display("T2: PASS - $clog2(1) = %0d", val);
                pass_count++;
            end else begin
                $display("T2: FAIL - $clog2(1) = %0d (expected 0)", val);
            end
        end

        // Test 3: $clog2(0) = 0
        begin
            static int val = $clog2(0);
            if (val == 0) begin
                $display("T3: PASS - $clog2(0) = %0d", val);
                pass_count++;
            end else begin
                $display("T3: FAIL - $clog2(0) = %0d (expected 0)", val);
            end
        end

        // Test 4: $clog2 non-power-of-2
        begin
            static int val = $clog2(5);
            if (val == 3) begin
                $display("T4: PASS - $clog2(5) = %0d", val);
                pass_count++;
            end else begin
                $display("T4: FAIL - $clog2(5) = %0d (expected 3)", val);
            end
        end

        // Test 5: $countones
        begin
            static logic [7:0] val = 8'b10110100;
            int cnt;
            // Assigned here so the result does not depend on the order of static initializers.
            cnt = $countones(val);
            if (cnt == 4) begin
                $display("T5: PASS - $countones(8'b10110100) = %0d", cnt);
                pass_count++;
            end else begin
                $display("T5: FAIL - $countones = %0d (expected 4)", cnt);
            end
        end

        // Test 6: $countones all zeros
        begin
            static logic [7:0] val = 8'b00000000;
            int cnt;
            // Assigned here so the result does not depend on the order of static initializers.
            cnt = $countones(val);
            if (cnt == 0) begin
                $display("T6: PASS - $countones(0) = %0d", cnt);
                pass_count++;
            end else begin
                $display("T6: FAIL - $countones(0) = %0d (expected 0)", cnt);
            end
        end

        // Test 7: $onehot
        begin
            static logic [7:0] val = 8'b00010000;
            if ($onehot(val)) begin
                $display("T7: PASS - $onehot(8'b00010000) = 1");
                pass_count++;
            end else begin
                $display("T7: FAIL - $onehot(8'b00010000) = 0 (expected 1)");
            end
        end

        // Test 8: $onehot with multiple bits
        begin
            static logic [7:0] val = 8'b00010100;
            if (!$onehot(val)) begin
                $display("T8: PASS - $onehot(8'b00010100) = 0 (two bits set)");
                pass_count++;
            end else begin
                $display("T8: FAIL - $onehot(8'b00010100) = 1 (expected 0)");
            end
        end

        // Test 9: $onehot0
        begin
            static logic [7:0] val = 8'b00000000;
            if ($onehot0(val)) begin
                $display("T9: PASS - $onehot0(0) = 1 (zero is valid)");
                pass_count++;
            end else begin
                $display("T9: FAIL - $onehot0(0) = 0 (expected 1)");
            end
        end

        // Test 10: $isunknown with X
        begin
            static logic [7:0] val = 8'b1010x010;
            if ($isunknown(val)) begin
                $display("T10: PASS - $isunknown detects X");
                pass_count++;
            end else begin
                $display("T10: FAIL - $isunknown missed X value");
            end
        end

        // Test 11: $isunknown without X
        begin
            static logic [7:0] val = 8'b10100110;
            if (!$isunknown(val)) begin
                $display("T11: PASS - $isunknown(no X) = 0");
                pass_count++;
            end else begin
                $display("T11: FAIL - $isunknown false positive");
            end
        end

        // Test 12: $clog2 large value
        begin
            static int val = $clog2(1024);
            if (val == 10) begin
                $display("T12: PASS - $clog2(1024) = %0d", val);
                pass_count++;
            end else begin
                $display("T12: FAIL - $clog2(1024) = %0d (expected 10)", val);
            end
        end

        $display("pass_count = %0d", pass_count);
        if (pass_count >= 10)
            $display("PASS: test_comb_system_functions");
        else
            $display("FAIL: test_comb_system_functions (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
