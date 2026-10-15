/*
:name: test_assign_edge_cases
:description: Continuous assignment edge cases
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_edge_cases.expected
*/
// IEEE 1800-2023 §10.3: Continuous assignment edge cases
// Tests for assign statements

module test_assign_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic clk = 0;
    logic [7:0] a, b, c;
    logic [7:0] result1, result2;
    wire [7:0] wire_result;
    logic sel;

    assign wire_result = a + b;
    assign result1 = sel ? a : b;

    initial begin
        repeat(50) #5 clk = ~clk;
    end

    initial begin
        a = 8'h10;
        b = 8'h20;
        sel = 0;
        #1;

        // Test 1: Basic assign
        test_count++;
        if (wire_result == 8'h30) begin
            pass_count++;
            $display("Test 1 PASS: a+b = %h", wire_result);
        end else begin
            $display("Test 1 FAIL: Assign unexpected = %h", wire_result);
        end

        // Test 2: Conditional assign
        test_count++;
        if (result1 == b) begin
            pass_count++;
            $display("Test 2 PASS: sel=0, result = %h", result1);
        end else begin
            $display("Test 2 FAIL: Cond unexpected = %h", result1);
        end

        // Test 3: Change input
        test_count++;
        a = 8'hFF;
        #1;
        if (wire_result == 8'h1F) begin
            pass_count++;
            $display("Test 3 PASS: FF+20 = %h", wire_result);
        end else begin
            $display("Test 3 FAIL: Changed = %h", wire_result);
        end

        // Test 4: Change selector
        test_count++;
        sel = 1;
        #1;
        if (result1 == a) begin
            pass_count++;
            $display("Test 4 PASS: sel=1, result = %h", result1);
        end else begin
            $display("Test 4 FAIL: Sel unexpected = %h", result1);
        end

        // Test 5: Both inputs zero
        test_count++;
        a = 8'h00;
        b = 8'h00;
        #1;
        if (wire_result == 8'h00) begin
            pass_count++;
            $display("Test 5 PASS: 0+0 = %h", wire_result);
        end else begin
            $display("Test 5 FAIL: Zero unexpected = %h", wire_result);
        end

        // Test 6: Max values
        test_count++;
        a = 8'hFF;
        b = 8'hFF;
        #1;
        if (wire_result == 8'hFE) begin
            pass_count++;
            $display("Test 6 PASS: FF+FF = %h (overflow)", wire_result);
        end else begin
            $display("Test 6 FAIL: Max unexpected = %h", wire_result);
        end

        // Test 7: Rapid changes
        test_count++;
        for (int i = 0; i < 4; i++) begin
            a = i;
            b = i;
            #1;
        end
        pass_count++;
        $display("Test 7 PASS: Rapid changes");

        // Test 8: Assign propagation
        test_count++;
        a = 8'h12;
        b = 8'h34;
        #0;  // Delta cycle
        if (wire_result == 8'h46) begin
            pass_count++;
            $display("Test 8 PASS: Delta = %h", wire_result);
        end else begin
            $display("Test 8 FAIL: Delta unexpected = %h", wire_result);
        end

        // Test 9: Toggle inputs
        test_count++;
        a = 8'hAA;
        b = 8'h55;
        #1;
        a = 8'h55;
        b = 8'hAA;
        #1;
        if (wire_result == 8'hFF) begin
            pass_count++;
            $display("Test 9 PASS: Toggle = %h", wire_result);
        end else begin
            $display("Test 9 FAIL: Toggle unexpected = %h", wire_result);
        end

        // Test 10: Selector toggle
        test_count++;
        sel = 0;
        #1;
        sel = 1;
        #1;
        sel = 0;
        #1;
        pass_count++;
        $display("Test 10 PASS: Selector toggle");

        $display("=== Assign Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
