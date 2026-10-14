/*
:name: test_multi_sensitivity_list
:description: Multi-signal sensitivity list test
:tags: edge_cases
:type: simulation
:lrm: 1800-2023 9.4.2
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_multi_sensitivity_list.expected
*/
// IEEE 1800-2023 §9.4.2: Multi-signal sensitivity list test
// Tests @(posedge clk or negedge rst_n) style always blocks

module test_multi_sensitivity_list;
    logic clk = 0;
    logic rst_n = 1;
    logic [7:0] q = 0;
    logic [7:0] d = 8'hAB;

    // Test 1: Synchronous register with async reset (posedge clk or negedge rst_n)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 8'h00;
        else
            q <= d;
    end

    // Test 2: Counter with both edges and async reset
    logic [3:0] counter = 0;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= 4'h0;
        else
            counter <= counter + 1;
    end

    // Test 3: Level-sensitive sensitivity list
    logic [3:0] level_out = 0;
    logic enable = 0;
    logic [3:0] level_in = 4'h5;
    always @(enable or level_in) begin
        if (enable)
            level_out = level_in;
        else
            level_out = 4'h0;
    end

    // Test 4: Multi-signal edge sensitivity
    logic a = 0;
    logic b = 0;
    logic [1:0] multi_edge_result = 0;
    always @(posedge a or posedge b) begin
        multi_edge_result <= multi_edge_result + 1;
    end

    int test_count = 0;
    int pass_count = 0;

    initial begin
        // Test 1: Check initial state after async reset (rst_n already 1)
        test_count++;
        if (q == 0 && counter == 0) begin
            $display("TEST 1 PASS: Initial state correct (q=%0d, counter=%0d)", q, counter);
            pass_count++;
        end else begin
            $display("TEST 1 FAIL: Initial state incorrect (q=%0d, counter=%0d)", q, counter);
        end

        // Test 2: Apply async reset
        rst_n = 0;
        #1;
        test_count++;
        if (q == 0 && counter == 0) begin
            $display("TEST 2 PASS: Async reset applied (q=%0d, counter=%0d)", q, counter);
            pass_count++;
        end else begin
            $display("TEST 2 FAIL: Async reset not applied (q=%0d, counter=%0d)", q, counter);
        end

        // Test 3: Release reset and trigger clock
        rst_n = 1;
        #1;
        clk = 1;  // Rising edge
        #1;
        clk = 0;  // Falling edge (should not trigger)
        #1;
        test_count++;
        if (q == 8'hAB && counter == 1) begin
            $display("TEST 3 PASS: Clock edge after reset release (q=%h, counter=%0d)", q, counter);
            pass_count++;
        end else begin
            $display("TEST 3 FAIL: Clock edge not properly handled (q=%h, counter=%0d)", q, counter);
        end

        // Test 4: Test level-sensitive sensitivity list
        enable = 1;
        #1;
        test_count++;
        if (level_out == 4'h5) begin
            $display("TEST 4 PASS: Level-sensitive sensitivity (level_out=%h)", level_out);
            pass_count++;
        end else begin
            $display("TEST 4 FAIL: Level-sensitive sensitivity (level_out=%h)", level_out);
        end

        // Test 5: Change level_in while enabled
        level_in = 4'hA;
        #1;
        test_count++;
        if (level_out == 4'hA) begin
            $display("TEST 5 PASS: Level input change (level_out=%h)", level_out);
            pass_count++;
        end else begin
            $display("TEST 5 FAIL: Level input change (level_out=%h)", level_out);
        end

        // Test 6: Multi-signal posedge
        a = 1;  // Posedge a
        #1;
        test_count++;
        if (multi_edge_result == 1) begin
            $display("TEST 6 PASS: Multi-signal posedge a (multi_edge_result=%0d)", multi_edge_result);
            pass_count++;
        end else begin
            $display("TEST 6 FAIL: Multi-signal posedge a (multi_edge_result=%0d)", multi_edge_result);
        end

        // Test 7: Multi-signal posedge b
        b = 1;  // Posedge b
        #1;
        test_count++;
        if (multi_edge_result == 2) begin
            $display("TEST 7 PASS: Multi-signal posedge b (multi_edge_result=%0d)", multi_edge_result);
            pass_count++;
        end else begin
            $display("TEST 7 FAIL: Multi-signal posedge b (multi_edge_result=%0d)", multi_edge_result);
        end

        // Summary
        $display("\n=== Test Summary ===");
        $display("Passed: %0d / %0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("All tests PASSED!");
        end else begin
            $display("Some tests FAILED!");
        end

        $finish;
    end
endmodule
