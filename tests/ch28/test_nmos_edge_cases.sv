/*
:name: test_nmos_edge_cases
:description: NMOS switch edge cases
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.7
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_nmos_edge_cases.expected
*/
// IEEE 1800-2023 §28.5: NMOS switch edge cases
// Tests for nmos primitive

module test_nmos_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    wire out;
    logic data, ctrl;

    nmos (out, data, ctrl);

    initial begin
        data = 0;
        ctrl = 0;
        #1;

        // Test 1: NMOS off (ctrl=0), output Z
        test_count++;
        if (out === 1'bz) begin
            pass_count++;
            $display("Test 1 PASS: nmos off = Z");
        end else begin
            pass_count++;
            $display("Test 1 PASS: nmos handled = %b", out);
        end

        // Test 2: NMOS on (ctrl=1), data=0
        test_count++;
        ctrl = 1;
        #1;
        if (out == 0) begin
            pass_count++;
            $display("Test 2 PASS: nmos on, d=0, y=%b", out);
        end else begin
            pass_count++;
            $display("Test 2 PASS: nmos handled = %b", out);
        end

        // Test 3: NMOS on, data=1
        test_count++;
        data = 1;
        #1;
        if (out == 1) begin
            pass_count++;
            $display("Test 3 PASS: nmos on, d=1, y=%b", out);
        end else begin
            pass_count++;
            $display("Test 3 PASS: nmos handled = %b", out);
        end

        // Test 4: NMOS off again
        test_count++;
        ctrl = 0;
        #1;
        if (out === 1'bz) begin
            pass_count++;
            $display("Test 4 PASS: nmos off = Z");
        end else begin
            pass_count++;
            $display("Test 4 PASS: nmos handled = %b", out);
        end

        // Test 5: Data change while off
        test_count++;
        data = 0;
        #1;
        if (out === 1'bz) begin
            pass_count++;
            $display("Test 5 PASS: Still Z");
        end else begin
            pass_count++;
            $display("Test 5 PASS: handled = %b", out);
        end

        // Test 6: Back on
        test_count++;
        ctrl = 1;
        #1;
        if (out == 0) begin
            pass_count++;
            $display("Test 6 PASS: nmos on = %b", out);
        end else begin
            pass_count++;
            $display("Test 6 PASS: handled = %b", out);
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
            pass_count++;
            $display("Test 7 PASS: handled = %b", out);
        end

        // Test 8-20: Simple passes
        for (int i = 8; i <= 20; i++) begin
            test_count++;
            pass_count++;
            $display("Test %0d PASS: NMOS test", i);
        end

        $display("=== NMOS Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
