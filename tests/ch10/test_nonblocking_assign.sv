/*
:name: test_nonblocking_assign
:description: Non-blocking Assignments Tests
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonblocking_assign.expected
*/
// IEEE 1800-2023 Section 10.4.2 - Non-blocking Assignments Tests
// Tests: NBA in sequential blocks, NBA with delays

module test_nonblocking_assign;
    int pass_count = 0;
    int fail_count = 0;

    logic clk = 0;
    logic [7:0] reg_a, reg_b, reg_c;
    int counter;

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("=== IEEE 1800-2023 Non-blocking Assignment Tests ===");

        // Test 1: Simple NBA
        $display("Test 1: Simple NBA");
        reg_a = 8'h00;
        @(posedge clk);
        reg_a <= 8'hAA;
        @(posedge clk);
        if (reg_a == 8'hAA) begin
            $display("Test 1 PASS: reg_a=%h", reg_a);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: reg_a=%h", reg_a);
            fail_count++;
        end

        // Test 2: Multiple NBA same cycle
        $display("Test 2: Multiple NBA same cycle");
        @(posedge clk);
        reg_a <= 8'h11;
        reg_b <= 8'h22;
        reg_c <= 8'h33;
        @(posedge clk);
        if (reg_a == 8'h11 && reg_b == 8'h22 && reg_c == 8'h33) begin
            $display("Test 2 PASS: a=%h, b=%h, c=%h", reg_a, reg_b, reg_c);
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: NBA chain
        $display("Test 3: NBA chain");
        reg_a = 8'h00;
        reg_b = 8'h00;
        @(posedge clk);
        reg_a <= 8'hFF;
        @(posedge clk);
        reg_b <= reg_a;
        @(posedge clk);
        if (reg_b == 8'hFF) begin
            $display("Test 3 PASS: reg_b=%h", reg_b);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: reg_b=%h", reg_b);
            fail_count++;
        end

        // Test 4: NBA with expression
        $display("Test 4: NBA with expression");
        reg_a = 8'h10;
        @(posedge clk);
        reg_a <= reg_a + 8'h05;
        @(posedge clk);
        if (reg_a == 8'h15) begin
            $display("Test 4 PASS: reg_a=%h", reg_a);
            pass_count++;
        end else begin
            $display("Test 4 FAIL");
            fail_count++;
        end

        // Test 5: Counter with NBA
        $display("Test 5: Counter with NBA");
        counter = 0;
        repeat(3) begin
            @(posedge clk);
            counter <= counter + 1;
            @(posedge clk);
        end
        if (counter == 3) begin
            $display("Test 5 PASS: counter=%0d", counter);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: counter=%0d", counter);
            fail_count++;
        end

        // Test 6: NBA vs blocking order
        $display("Test 6: NBA vs blocking order");
        reg_a = 8'h00;
        reg_b = 8'h00;
        @(posedge clk);
        reg_a = 8'h55;      // Blocking - immediate
        reg_b <= 8'h55;     // NBA - deferred
        if (reg_a == 8'h55) begin
            $display("Test 6 PASS: blocking immediate");
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: Verify NBA took effect
        $display("Test 7: NBA takes effect after cycle");
        @(posedge clk);
        if (reg_b == 8'h55) begin
            $display("Test 7 PASS: reg_b=%h", reg_b);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: reg_b=%h", reg_b);
            fail_count++;
        end

        // Test 8: NBA in loop
        $display("Test 8: NBA in loop");
        reg_a = 8'h00;
        for (int i = 0; i < 4; i++) begin
            @(posedge clk);
            reg_a <= reg_a + 8'h01;
        end
        @(posedge clk);
        if (reg_a == 8'h04) begin
            $display("Test 8 PASS: reg_a=%h", reg_a);
            pass_count++;
        end else begin
            $display("Test 8 FAIL: reg_a=%h", reg_a);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
