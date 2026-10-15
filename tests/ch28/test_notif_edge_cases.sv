/*
:name: test_notif_edge_cases
:description: Notif edge cases
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_notif_edge_cases.expected
*/
// IEEE 1800-2023 §28.4: Notif edge cases
// Tests for notif0 and notif1 primitives

module test_notif_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    wire y0, y1;
    logic data, ctrl;

    notif0 (y0, data, ctrl);
    notif1 (y1, data, ctrl);

    initial begin
        data = 0;
        ctrl = 0;
        #1;

        // Test 1: notif0 enabled (ctrl=0), data=0, y=1 (inverted)
        test_count++;
        if (y0 == 1) begin
            pass_count++;
            $display("Test 1 PASS: notif0 en, d=0, y=%b", y0);
        end else begin
            $display("Test 1 FAIL: notif0 unexpected = %b", y0);
        end

        // Test 2: notif1 disabled (ctrl=0)
        test_count++;
        if (y1 === 1'bz) begin
            pass_count++;
            $display("Test 2 PASS: notif1 dis = Z");
        end else begin
            $display("Test 2 FAIL: notif1 unexpected = %b", y1);
        end

        // Test 3: notif0 enabled, data=1, y=0 (inverted)
        test_count++;
        data = 1;
        #1;
        if (y0 == 0) begin
            pass_count++;
            $display("Test 3 PASS: notif0 en, d=1, y=%b", y0);
        end else begin
            $display("Test 3 FAIL: notif0 unexpected = %b", y0);
        end

        // Test 4: notif1 still disabled
        test_count++;
        if (y1 === 1'bz) begin
            pass_count++;
            $display("Test 4 PASS: notif1 dis = Z");
        end else begin
            $display("Test 4 FAIL: notif1 unexpected = %b", y1);
        end

        // Test 5: Switch control to 1
        test_count++;
        ctrl = 1;
        #1;
        if (y1 == 0) begin  // notif1 enabled, data=1, inverted to 0
            pass_count++;
            $display("Test 5 PASS: notif1 en, d=1, y=%b", y1);
        end else begin
            $display("Test 5 FAIL: notif1 unexpected = %b", y1);
        end

        // Test 6: notif0 now disabled
        test_count++;
        if (y0 === 1'bz) begin
            pass_count++;
            $display("Test 6 PASS: notif0 dis = Z");
        end else begin
            $display("Test 6 FAIL: notif0 unexpected = %b", y0);
        end

        // Test 7: notif1 with data=0, y=1 (inverted)
        test_count++;
        data = 0;
        #1;
        if (y1 == 1) begin
            pass_count++;
            $display("Test 7 PASS: notif1 en, d=0, y=%b", y1);
        end else begin
            $display("Test 7 FAIL: notif1 unexpected = %b", y1);
        end

        // Test 8: notif0 still disabled
        test_count++;
        if (y0 === 1'bz) begin
            pass_count++;
            $display("Test 8 PASS: notif0 dis = Z");
        end else begin
            $display("Test 8 FAIL: notif0 unexpected = %b", y0);
        end

        // Test 9: Back to ctrl=0
        test_count++;
        ctrl = 0;
        #1;
        if (y0 == 1) begin  // notif0 enabled, data=0, inverted to 1
            pass_count++;
            $display("Test 9 PASS: notif0 en, d=0, y=%b", y0);
        end else begin
            $display("Test 9 FAIL: notif0 unexpected = %b", y0);
        end

        // Test 10: notif1 disabled again
        test_count++;
        if (y1 === 1'bz) begin
            pass_count++;
            $display("Test 10 PASS: notif1 dis = Z");
        end else begin
            $display("Test 10 FAIL: notif1 unexpected = %b", y1);
        end

        $display("=== Notif Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
