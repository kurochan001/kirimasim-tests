/*
:name: test_pmos_edge_cases
:description: PMOS switch edge cases
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_pmos_edge_cases.expected
*/
// IEEE 1800-2023 §28.5: PMOS switch edge cases
// Tests for pmos primitive

module test_pmos_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    wire out;
    logic data, ctrl;

    pmos (out, data, ctrl);

    initial begin
        data = 0;
        ctrl = 1;
        #1;

        // Test 1: PMOS off (ctrl=1), output Z
        test_count++;
        if (out === 1'bz) begin
            pass_count++;
            $display("Test 1 PASS: pmos off = Z");
        end else begin
            $display("Test 1 FAIL: pmos unexpected = %b", out);
        end

        // Test 2: PMOS on (ctrl=0), data=0
        test_count++;
        ctrl = 0;
        #1;
        if (out == 0) begin
            pass_count++;
            $display("Test 2 PASS: pmos on, d=0, y=%b", out);
        end else begin
            $display("Test 2 FAIL: pmos unexpected = %b", out);
        end

        // Test 3: PMOS on, data=1
        test_count++;
        data = 1;
        #1;
        if (out == 1) begin
            pass_count++;
            $display("Test 3 PASS: pmos on, d=1, y=%b", out);
        end else begin
            $display("Test 3 FAIL: pmos unexpected = %b", out);
        end

        // Test 4: PMOS off again
        test_count++;
        ctrl = 1;
        #1;
        if (out === 1'bz) begin
            pass_count++;
            $display("Test 4 PASS: pmos off = Z");
        end else begin
            $display("Test 4 FAIL: pmos unexpected = %b", out);
        end

        // Test 5: Data change while off
        test_count++;
        data = 0;
        #1;
        if (out === 1'bz) begin
            pass_count++;
            $display("Test 5 PASS: Still Z");
        end else begin
            $display("Test 5 FAIL: unexpected = %b", out);
        end

        // Test 6: Back on
        test_count++;
        ctrl = 0;
        #1;
        if (out == 0) begin
            pass_count++;
            $display("Test 6 PASS: pmos on = %b", out);
        end else begin
            $display("Test 6 FAIL: unexpected = %b", out);
        end

        // Test 7: Toggle data
        test_count++;
        data = 1;
        #1;
        data = 0;
        #1;
        if (out == 0) begin
            pass_count++;
            $display("Test 7 PASS: Toggle = %b", out);
        end else begin
            $display("Test 7 FAIL: unexpected = %b", out);
        end

        $display("=== PMOS Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
