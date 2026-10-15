/*
:name: test_sens_multi
:description: Multiple sensitivity
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sens_multi.expected
*/
// Multiple sensitivity
// Verifies always blocks with multiple sensitivity signals

module test_sens_multi;
    logic clk, rst_n, en;
    logic [7:0] d, q;
    logic a, b, c;
    logic [7:0] comb_out;
    logic sig1, sig2, sig3;
    logic [3:0] trigger_count;
    int pass_count = 0;
    int fail_count = 0;

    // Scenario 1: Clock with async reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 8'h00;
        else
            q <= d;
    end

    // Scenario 2: Multiple level triggers
    always @(a or b or c) begin
        comb_out = {5'b0, a, b, c};
    end

    // Scenario 3: Multiple edge triggers
    always @(posedge sig1 or posedge sig2 or posedge sig3) begin
        trigger_count <= trigger_count + 1;
    end

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Initialize
        rst_n = 1;
        en = 0;
        d = 8'h00;
        a = 0; b = 0; c = 0;
        sig1 = 0; sig2 = 0; sig3 = 0;
        trigger_count = 4'h0;

        #1;

        // Test 1: Async reset (rst_n=0 without clock)
        rst_n = 0;
        #1;
        if (q === 8'h00) begin
            $display("PASS: Scenario 1 - Async reset active (q=0x%h)", q);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 1 - q=0x%h (expected 0x00)", q);
            fail_count++;
        end

        // Test 2: Release reset and load data
        rst_n = 1;
        d = 8'hAB;
        @(posedge clk);
        #1;
        if (q === 8'hAB) begin
            $display("PASS: Scenario 2 - Normal operation after reset (q=0x%h)", q);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 2 - q=0x%h (expected 0xAB)", q);
            fail_count++;
        end

        // Test 3: Async reset mid-operation
        d = 8'hCD;
        #2;
        rst_n = 0;
        #1;
        if (q === 8'h00) begin
            $display("PASS: Scenario 3 - Mid-cycle async reset (q=0x%h)", q);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 3 - q=0x%h (expected 0x00)", q);
            fail_count++;
        end

        rst_n = 1;

        // Test 4: Multiple level triggers - change a
        a = 1;
        #1;
        if (comb_out === 8'h04) begin
            $display("PASS: Scenario 4 - Level trigger a (comb_out=0x%h)", comb_out);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 4 - comb_out=0x%h (expected 0x04)", comb_out);
            fail_count++;
        end

        // Test 5: Multiple level triggers - change b and c
        b = 1; c = 1;
        #1;
        if (comb_out === 8'h07) begin
            $display("PASS: Scenario 5 - Level triggers b,c (comb_out=0x%h)", comb_out);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 5 - comb_out=0x%h (expected 0x07)", comb_out);
            fail_count++;
        end

        // Test 6: Multiple posedge triggers
        sig1 = 1; // Rising edge
        #1;
        if (trigger_count === 4'h1) begin
            $display("PASS: Scenario 6a - sig1 posedge (count=%0d)", trigger_count);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 6a - trigger_count=%0d (expected 1)", trigger_count);
            fail_count++;
        end

        sig2 = 1; // Rising edge
        #1;
        if (trigger_count === 4'h2) begin
            $display("PASS: Scenario 6b - sig2 posedge (count=%0d)", trigger_count);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 6b - trigger_count=%0d (expected 2)", trigger_count);
            fail_count++;
        end

        sig3 = 1; // Rising edge
        #1;
        if (trigger_count === 4'h3) begin
            $display("PASS: Scenario 6c - sig3 posedge (count=%0d)", trigger_count);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 6c - trigger_count=%0d (expected 3)", trigger_count);
            fail_count++;
        end

        // Summary
        $display("Multiple sensitivity: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS");
        else $display("FAIL");
        $finish;
    end
endmodule
