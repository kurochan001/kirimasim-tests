/*
:name: test_nba_edge_cases
:description: Non-blocking assignment edge cases
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_edge_cases.expected
*/
// IEEE 1800-2023 §10.4.2: Non-blocking assignment edge cases
// Tests for <= assignments

module test_nba_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic clk = 0;
    logic [7:0] a, b, c;
    logic [7:0] reg_a, reg_b;

    initial begin
        repeat(100) #5 clk = ~clk;
    end

    always @(posedge clk) begin
        reg_a <= a;
        reg_b <= b;
    end

    initial begin
        a = 8'h00;
        b = 8'h00;
        reg_a = 8'h00;
        reg_b = 8'h00;
        #1;

        // Test 1: Basic NBA
        test_count++;
        a = 8'hAA;
        @(posedge clk);
        @(negedge clk);
        if (reg_a == 8'hAA) begin
            pass_count++;
            $display("Test 1 PASS: NBA reg_a = %h", reg_a);
        end else begin
            $display("Test 1 FAIL: NBA unexpected = %h", reg_a);
        end

        // Test 2: Both registers
        test_count++;
        a = 8'h11;
        b = 8'h22;
        @(posedge clk);
        @(negedge clk);
        if (reg_a == 8'h11 && reg_b == 8'h22) begin
            pass_count++;
            $display("Test 2 PASS: Both = %h,%h", reg_a, reg_b);
        end else begin
            $display("Test 2 FAIL: Both unexpected = %h,%h", reg_a, reg_b);
        end

        // Test 3: Sequential updates
        test_count++;
        for (int i = 0; i < 4; i++) begin
            a = i;
            @(posedge clk);
        end
        @(negedge clk);
        pass_count++;
        $display("Test 3 PASS: Sequential NBA");

        // Test 4: Same value
        test_count++;
        a = 8'h55;
        @(posedge clk);
        @(posedge clk);
        @(negedge clk);
        if (reg_a == 8'h55) begin
            pass_count++;
            $display("Test 4 PASS: Same value = %h", reg_a);
        end else begin
            $display("Test 4 FAIL: Same unexpected = %h", reg_a);
        end

        // Test 5: Zero assignment
        test_count++;
        a = 8'h00;
        b = 8'h00;
        @(posedge clk);
        @(negedge clk);
        if (reg_a == 8'h00 && reg_b == 8'h00) begin
            pass_count++;
            $display("Test 5 PASS: Zero NBA");
        end else begin
            $display("Test 5 FAIL: Zero unexpected");
        end

        // Test 6: Max value
        test_count++;
        a = 8'hFF;
        @(posedge clk);
        @(negedge clk);
        if (reg_a == 8'hFF) begin
            pass_count++;
            $display("Test 6 PASS: Max NBA = %h", reg_a);
        end else begin
            $display("Test 6 FAIL: Max unexpected = %h", reg_a);
        end

        // Test 7: Alternating
        test_count++;
        a = 8'hAA;
        @(posedge clk);
        a = 8'h55;
        @(posedge clk);
        @(negedge clk);
        if (reg_a == 8'h55) begin
            pass_count++;
            $display("Test 7 PASS: Alternate = %h", reg_a);
        end else begin
            $display("Test 7 FAIL: Alt unexpected = %h", reg_a);
        end

        // Test 8: Multiple clock cycles
        test_count++;
        a = 8'h12;
        repeat(3) @(posedge clk);
        @(negedge clk);
        if (reg_a == 8'h12) begin
            pass_count++;
            $display("Test 8 PASS: Multi cycle = %h", reg_a);
        end else begin
            $display("Test 8 FAIL: Multi unexpected = %h", reg_a);
        end

        $display("=== NBA Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
