/*
:name: test_always_comb_sens
:description: always_comb sensitivity
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_sens.expected
*/
// always_comb sensitivity
// Verifies that always_comb blocks automatically trigger on signal changes

module test_always_comb_sens;
    logic a, b, c;
    logic [3:0] x, y, z;
    logic out1, out2;
    logic [3:0] out3, out4, out5;
    int pass_count = 0;
    int fail_count = 0;

    // Scenario 1: Simple combinational logic
    always_comb begin
        out1 = a & b;
    end

    // Scenario 2: Multi-input combinational
    always_comb begin
        out2 = a | b | c;
    end

    // Scenario 3: Arithmetic combinational
    always_comb begin
        out3 = x + y;
    end

    // Scenario 4: Conditional combinational
    always_comb begin
        if (a)
            out4 = x;
        else
            out4 = y;
    end

    // Scenario 5: Complex expression
    always_comb begin
        out5 = (x & y) | (z ^ 4'hF);
    end

    initial begin
        // Test 1: Initial state
        a = 0; b = 0; c = 0;
        x = 4'h0; y = 4'h0; z = 4'h0;
        #1;
        if (out1 === 1'b0 && out2 === 1'b0) begin
            $display("PASS: Scenario 1 - Initial state correct");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 1 - out1=%b, out2=%b (expected 0, 0)", out1, out2);
            fail_count++;
        end

        // Test 2: Change a - should trigger always_comb
        a = 1;
        #1;
        if (out1 === 1'b0 && out2 === 1'b1) begin
            $display("PASS: Scenario 2 - a=1 triggers update");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 2 - out1=%b, out2=%b (expected 0, 1)", out1, out2);
            fail_count++;
        end

        // Test 3: Change b - should trigger AND gate
        b = 1;
        #1;
        if (out1 === 1'b1) begin
            $display("PASS: Scenario 3 - AND gate correct");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 3 - out1=%b (expected 1)", out1);
            fail_count++;
        end

        // Test 4: Arithmetic update
        x = 4'h5; y = 4'h3;
        #1;
        if (out3 === 4'h8) begin
            $display("PASS: Scenario 4 - Arithmetic out3=0x%h", out3);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 4 - out3=0x%h (expected 0x8)", out3);
            fail_count++;
        end

        // Test 5: Conditional mux (a=1, so out4=x)
        #1;
        if (out4 === 4'h5) begin
            $display("PASS: Scenario 5 - Conditional mux correct");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 5 - out4=0x%h (expected 0x5)", out4);
            fail_count++;
        end

        // Summary
        $display("always_comb sensitivity: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS");
        else $display("FAIL");
        $finish;
    end
endmodule
