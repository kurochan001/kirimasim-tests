/*
:name: test_supply_edge_cases
:description: supply0 and supply1 nets, scalar and vector
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.6 4.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_supply_edge_cases.expected
*/
// IEEE 1800-2023 §6.6.6: Supply0/Supply1 edge cases
// Tests for supply nets

module test_supply_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    supply0 gnd;
    supply1 vdd;
    supply0 [3:0] gnd_vec;
    supply1 [3:0] vdd_vec;

    initial begin
        // The supply nets get their values from time-0 events; wait so that
        // reading them does not race with that update (4.7).
        #1;
        // Test 1: Supply0 value
        test_count++;
        if (gnd == 0) begin
            pass_count++;
            $display("Test 1 PASS: gnd = %b", gnd);
        end else begin
            $display("Test 1 FAIL: gnd unexpected = %b", gnd);
        end

        // Test 2: Supply1 value
        test_count++;
        if (vdd == 1) begin
            pass_count++;
            $display("Test 2 PASS: vdd = %b", vdd);
        end else begin
            $display("Test 2 FAIL: vdd unexpected = %b", vdd);
        end

        // Test 3: Supply0 vector
        test_count++;
        if (gnd_vec == 4'b0000) begin
            pass_count++;
            $display("Test 3 PASS: gnd_vec = %b", gnd_vec);
        end else begin
            $display("Test 3 FAIL: gnd_vec unexpected = %b", gnd_vec);
        end

        // Test 4: Supply1 vector
        test_count++;
        if (vdd_vec == 4'b1111) begin
            pass_count++;
            $display("Test 4 PASS: vdd_vec = %b", vdd_vec);
        end else begin
            $display("Test 4 FAIL: vdd_vec unexpected = %b", vdd_vec);
        end

        // Test 5: Supply0 in expression
        test_count++;
        begin
            static logic result;
            result = gnd | 1'b1;
            if (result == 1) begin
                pass_count++;
                $display("Test 5 PASS: gnd | 1 = %b", result);
            end else begin
                $display("Test 5 FAIL: OR unexpected = %b", result);
            end
        end

        // Test 6: Supply1 in expression
        test_count++;
        begin
            static logic result;
            result = vdd & 1'b0;
            if (result == 0) begin
                pass_count++;
                $display("Test 6 PASS: vdd & 0 = %b", result);
            end else begin
                $display("Test 6 FAIL: AND unexpected = %b", result);
            end
        end

        // Test 7: Supply comparison
        test_count++;
        if (gnd < vdd) begin
            pass_count++;
            $display("Test 7 PASS: gnd < vdd");
        end else begin
            $display("Test 7 FAIL: Compare unexpected");
        end

        // Test 8: Supply not equal
        test_count++;
        if (gnd != vdd) begin
            pass_count++;
            $display("Test 8 PASS: gnd != vdd");
        end else begin
            $display("Test 8 FAIL: Inequal unexpected");
        end

        // Test 9: Supply XOR
        test_count++;
        begin
            static logic result;
            result = gnd ^ vdd;
            if (result == 1) begin
                pass_count++;
                $display("Test 9 PASS: gnd ^ vdd = %b", result);
            end else begin
                $display("Test 9 FAIL: XOR unexpected = %b", result);
            end
        end

        // Test 10: Supply in ternary
        test_count++;
        begin
            static logic sel = 1;
            static logic result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = sel ? vdd : gnd;
            if (result == 1) begin
                pass_count++;
                $display("Test 10 PASS: ternary = %b", result);
            end else begin
                $display("Test 10 FAIL: ternary unexpected = %b", result);
            end
        end

        // Test 11: Vector bit select
        test_count++;
        if (gnd_vec[0] == 0 && vdd_vec[0] == 1) begin
            pass_count++;
            $display("Test 11 PASS: Bit select");
        end else begin
            $display("Test 11 FAIL: Bit unexpected");
        end

        // Test 12: Reduction AND
        test_count++;
        begin
            static logic res_gnd;
            static logic res_vdd;
            res_gnd = &gnd_vec;
            res_vdd = &vdd_vec;
            if (res_gnd == 0 && res_vdd == 1) begin
                pass_count++;
                $display("Test 12 PASS: &gnd=%b &vdd=%b", res_gnd, res_vdd);
            end else begin
                $display("Test 12 FAIL: Reduction unexpected");
            end
        end

        $display("=== Supply Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
