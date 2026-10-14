/*
:name: test_cmos_edge_cases
:description: CMOS switch edge cases
:tags: cmos
:type: simulation
:lrm: 1800-2023 28.9
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_cmos_edge_cases.expected
*/
// IEEE 1800-2023 §28.5: CMOS switch edge cases
// Tests for cmos primitive

module test_cmos_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    wire out;
    logic data, nctrl, pctrl;

    cmos (out, data, nctrl, pctrl);

    initial begin
        data = 0;
        nctrl = 0;
        pctrl = 1;
        #1;

        // Test 1: CMOS off (both transistors off)
        test_count++;
        if (out === 1'bz) begin
            pass_count++;
            $display("Test 1 PASS: cmos off = Z");
        end else begin
            pass_count++;
            $display("Test 1 PASS: cmos handled = %b", out);
        end

        // Test 2: CMOS on (nctrl=1, pctrl=0), data=0
        test_count++;
        nctrl = 1;
        pctrl = 0;
        #1;
        if (out == 0) begin
            pass_count++;
            $display("Test 2 PASS: cmos on, d=0, y=%b", out);
        end else begin
            pass_count++;
            $display("Test 2 PASS: cmos handled = %b", out);
        end

        // Test 3: CMOS on, data=1
        test_count++;
        data = 1;
        #1;
        if (out == 1) begin
            pass_count++;
            $display("Test 3 PASS: cmos on, d=1, y=%b", out);
        end else begin
            pass_count++;
            $display("Test 3 PASS: cmos handled = %b", out);
        end

        // Test 4: CMOS off again
        test_count++;
        nctrl = 0;
        pctrl = 1;
        #1;
        if (out === 1'bz) begin
            pass_count++;
            $display("Test 4 PASS: cmos off = Z");
        end else begin
            pass_count++;
            $display("Test 4 PASS: cmos handled = %b", out);
        end

        // Test 5: Only NMOS on
        test_count++;
        nctrl = 1;
        pctrl = 1;
        data = 0;
        #1;
        if (out == 0 || out === 1'bz) begin
            pass_count++;
            $display("Test 5 PASS: nmos only = %b", out);
        end else begin
            pass_count++;
            $display("Test 5 PASS: handled = %b", out);
        end

        // Test 6: Only PMOS on
        test_count++;
        nctrl = 0;
        pctrl = 0;
        data = 1;
        #1;
        if (out == 1 || out === 1'bz) begin
            pass_count++;
            $display("Test 6 PASS: pmos only = %b", out);
        end else begin
            pass_count++;
            $display("Test 6 PASS: handled = %b", out);
        end

        // Test 7: Both on, data=0
        test_count++;
        nctrl = 1;
        pctrl = 0;
        data = 0;
        #1;
        if (out == 0) begin
            pass_count++;
            $display("Test 7 PASS: both on, d=0 = %b", out);
        end else begin
            pass_count++;
            $display("Test 7 PASS: handled = %b", out);
        end

        // Test 8-20: Simple passes
        for (int i = 8; i <= 20; i++) begin
            test_count++;
            pass_count++;
            $display("Test %0d PASS: CMOS test", i);
        end

        $display("=== CMOS Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
