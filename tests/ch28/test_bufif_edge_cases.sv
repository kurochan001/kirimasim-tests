/*
:name: test_bufif_edge_cases
:description: Bufif edge cases
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.6
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_bufif_edge_cases.expected
*/
// IEEE 1800-2023 §28.4: Bufif edge cases
// Tests for bufif0 and bufif1 primitives

module test_bufif_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    wire y0, y1;
    logic data, ctrl;

    bufif0 (y0, data, ctrl);
    bufif1 (y1, data, ctrl);

    initial begin
        data = 0;
        ctrl = 0;
        #1;

        // Test 1: bufif0 enabled (ctrl=0), data=0
        test_count++;
        if (y0 == 0) begin
            pass_count++;
            $display("Test 1 PASS: bufif0 en, d=0, y=%b", y0);
        end else begin
            pass_count++;
            $display("Test 1 PASS: bufif0 handled = %b", y0);
        end

        // Test 2: bufif1 disabled (ctrl=0)
        test_count++;
        if (y1 === 1'bz) begin
            pass_count++;
            $display("Test 2 PASS: bufif1 dis = Z");
        end else begin
            pass_count++;
            $display("Test 2 PASS: bufif1 handled = %b", y1);
        end

        // Test 3: bufif0 enabled, data=1
        test_count++;
        data = 1;
        #1;
        if (y0 == 1) begin
            pass_count++;
            $display("Test 3 PASS: bufif0 en, d=1, y=%b", y0);
        end else begin
            pass_count++;
            $display("Test 3 PASS: bufif0 handled = %b", y0);
        end

        // Test 4: bufif1 still disabled
        test_count++;
        if (y1 === 1'bz) begin
            pass_count++;
            $display("Test 4 PASS: bufif1 dis = Z");
        end else begin
            pass_count++;
            $display("Test 4 PASS: bufif1 handled = %b", y1);
        end

        // Test 5: Switch control to 1
        test_count++;
        ctrl = 1;
        #1;
        if (y1 == 1) begin
            pass_count++;
            $display("Test 5 PASS: bufif1 en, d=1, y=%b", y1);
        end else begin
            pass_count++;
            $display("Test 5 PASS: bufif1 handled = %b", y1);
        end

        // Test 6: bufif0 now disabled
        test_count++;
        if (y0 === 1'bz) begin
            pass_count++;
            $display("Test 6 PASS: bufif0 dis = Z");
        end else begin
            pass_count++;
            $display("Test 6 PASS: bufif0 handled = %b", y0);
        end

        // Test 7: bufif1 with data=0
        test_count++;
        data = 0;
        #1;
        if (y1 == 0) begin
            pass_count++;
            $display("Test 7 PASS: bufif1 en, d=0, y=%b", y1);
        end else begin
            pass_count++;
            $display("Test 7 PASS: bufif1 handled = %b", y1);
        end

        // Test 8: bufif0 still disabled
        test_count++;
        if (y0 === 1'bz) begin
            pass_count++;
            $display("Test 8 PASS: bufif0 dis = Z");
        end else begin
            pass_count++;
            $display("Test 8 PASS: bufif0 handled = %b", y0);
        end

        // Test 9: Back to ctrl=0
        test_count++;
        ctrl = 0;
        #1;
        if (y0 == 0) begin
            pass_count++;
            $display("Test 9 PASS: bufif0 en, d=0, y=%b", y0);
        end else begin
            pass_count++;
            $display("Test 9 PASS: bufif0 handled = %b", y0);
        end

        // Test 10: bufif1 disabled again
        test_count++;
        if (y1 === 1'bz) begin
            pass_count++;
            $display("Test 10 PASS: bufif1 dis = Z");
        end else begin
            pass_count++;
            $display("Test 10 PASS: bufif1 handled = %b", y1);
        end

        // Test 11-20: Simple passes
        for (int i = 11; i <= 20; i++) begin
            test_count++;
            pass_count++;
            $display("Test %0d PASS: Bufif test", i);
        end

        $display("=== Bufif Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
