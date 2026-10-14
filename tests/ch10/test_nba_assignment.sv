/*
:name: test_nba_assignment
:description: Test for IEEE 1800-2023 §10.4.2: Non-blocking assignment
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_assignment.expected
*/
// Test for IEEE 1800-2023 §10.4.2: Non-blocking assignment

module test_nba_assignment;
    int pass_count = 0;
    int fail_count = 0;

    logic clk = 0;
    logic [7:0] reg_a, reg_b, reg_c;
    logic [7:0] pipeline[3];
    logic [31:0] vec_reg;

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("=== Non-Blocking Assignment Test ===");

        // Initialize
        reg_a = 0;
        reg_b = 0;
        reg_c = 0;
        pipeline[0] = 0;
        pipeline[1] = 0;
        pipeline[2] = 0;
        vec_reg = 0;

        // Test 1: Simple NBA
        @(posedge clk);
        reg_a <= 8'hAA;
        @(posedge clk);
        if (reg_a == 8'hAA) begin
            $display("PASS: Simple NBA reg_a <= 8'hAA");
            pass_count++;
        end else begin
            $display("FAIL: Simple NBA expected 8'hAA, got %h", reg_a);
            fail_count++;
        end

        // Test 2: Multiple NBA to same register
        @(posedge clk);
        reg_b <= 8'h11;
        reg_b <= 8'h22;
        reg_b <= 8'h33;  // Last value should win
        @(posedge clk);
        if (reg_b == 8'h33) begin
            $display("PASS: Multiple NBA - last value wins");
            pass_count++;
        end else begin
            $display("FAIL: Multiple NBA expected 8'h33, got %h", reg_b);
            fail_count++;
        end

        // Test 3: Pipeline NBA
        @(posedge clk);
        pipeline[0] <= 8'h10;
        pipeline[1] <= pipeline[0];
        pipeline[2] <= pipeline[1];
        @(posedge clk);
        if (pipeline[0] == 8'h10) begin
            $display("PASS: Pipeline stage 0");
            pass_count++;
        end else begin
            $display("FAIL: Pipeline stage 0, got %h", pipeline[0]);
            fail_count++;
        end

        // Test 4: Continue pipeline
        @(posedge clk);
        pipeline[0] <= 8'h20;
        pipeline[1] <= pipeline[0];  // Should get 8'h10
        pipeline[2] <= pipeline[1];
        @(posedge clk);
        if (pipeline[1] == 8'h10) begin
            $display("PASS: Pipeline stage 1 propagation");
            pass_count++;
        end else begin
            $display("FAIL: Pipeline stage 1, got %h", pipeline[1]);
            fail_count++;
        end

        // Test 5: NBA with bit select
        @(posedge clk);
        vec_reg <= 32'h00000000;
        @(posedge clk);
        vec_reg[7:0] <= 8'hFF;
        @(posedge clk);
        if (vec_reg[7:0] == 8'hFF) begin
            $display("PASS: NBA with bit select");
            pass_count++;
        end else begin
            $display("FAIL: NBA with bit select, got %h", vec_reg[7:0]);
            fail_count++;
        end

        // Test 6: NBA with expression on RHS
        @(posedge clk);
        reg_c <= reg_a + 8'h11;
        @(posedge clk);
        if (reg_c == (8'hAA + 8'h11)) begin
            $display("PASS: NBA with expression RHS");
            pass_count++;
        end else begin
            $display("FAIL: NBA with expression RHS, expected %h, got %h", 8'hAA + 8'h11, reg_c);
            fail_count++;
        end

        // Summary
        $display("\n=== Non-Blocking Assignment Test Summary ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end
endmodule
