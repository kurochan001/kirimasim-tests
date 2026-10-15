/*
:name: test_sens_level
:description: Level sensitivity
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2 4.7
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sens_level.expected
*/
// Level sensitivity
// Verifies level-sensitive always blocks

module test_sens_level;
    logic a, b, c;
    logic [7:0] x, y;
    logic out1;
    logic [7:0] out2, out3;
    int pass_count = 0;
    int fail_count = 0;

    // Scenario 1: Simple level sensitivity
    always @(a) begin
        out1 = ~a;
    end

    // Scenario 2: Multiple level signals
    always @(x or y) begin
        out2 = x + y;
    end

    // Scenario 3: Level sensitivity with conditional
    always @(a or b or c) begin
        if (a)
            out3 = 8'hAA;
        else if (b)
            out3 = 8'hBB;
        else if (c)
            out3 = 8'hCC;
        else
            out3 = 8'h00;
    end

    initial begin
        // Initialize. The inputs change only at time 1: at time 0 the always
        // blocks may not be waiting yet (4.7, 9.2.2), and the x-to-0 change
        // at time 1 is what triggers them.
        out1 = 0; out2 = 0; out3 = 0;
        #1;
        a = 0; b = 0; c = 0;
        x = 8'h00; y = 8'h00;
        #1;
        // Test 1: Initial trigger
        if (out1 === 1'b1) begin
            $display("PASS: Scenario 1 - Initial trigger (out1=%b)", out1);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 1 - out1=%b (expected 1)", out1);
            fail_count++;
        end

        // Test 2: Change a from 0 to 1
        a = 1;
        #1;
        if (out1 === 1'b0) begin
            $display("PASS: Scenario 2 - a=1 triggers (out1=%b)", out1);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 2 - out1=%b (expected 0)", out1);
            fail_count++;
        end

        // Test 3: Change x triggers out2
        x = 8'h10;
        #1;
        if (out2 === 8'h10) begin
            $display("PASS: Scenario 3 - x change triggers (out2=0x%h)", out2);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 3 - out2=0x%h (expected 0x10)", out2);
            fail_count++;
        end

        // Test 4: Change y also triggers out2
        y = 8'h05;
        #1;
        if (out2 === 8'h15) begin
            $display("PASS: Scenario 4 - y change triggers (out2=0x%h)", out2);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 4 - out2=0x%h (expected 0x15)", out2);
            fail_count++;
        end

        // Test 5: Conditional - a=1 takes priority
        #1;
        if (out3 === 8'hAA) begin
            $display("PASS: Scenario 5 - Conditional a=1 (out3=0x%h)", out3);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 5 - out3=0x%h (expected 0xAA)", out3);
            fail_count++;
        end

        // Test 6: Conditional - a=0, b=1
        a = 0; b = 1;
        #1;
        if (out3 === 8'hBB) begin
            $display("PASS: Scenario 6 - Conditional b=1 (out3=0x%h)", out3);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 6 - out3=0x%h (expected 0xBB)", out3);
            fail_count++;
        end

        // Summary
        $display("Level sensitivity: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS");
        else $display("FAIL");
        $finish;
    end
endmodule
