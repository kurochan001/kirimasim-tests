/*
:name: test_nba_basic
:description: Test for non-blocking assignment
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_basic.expected
*/
// Test for non-blocking assignment
// IEEE 1800-2023 §10.4.2

module test_nba_basic;
    logic clk = 0;
    logic [7:0] a, b, c;
    int pass_count = 0;
    int test_count = 0;

    always #5 clk = ~clk;

    initial begin
        // Test 1: Simple NBA
        test_count++;
        a = 8'h00;
        @(posedge clk);
        a <= 8'hAA;
        @(posedge clk);
        if (a == 8'hAA) begin
            $display("Test 1: Simple NBA PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Multiple NBA same signal
        test_count++;
        b <= 8'h11;
        b <= 8'h22;
        b <= 8'h33;
        @(posedge clk);
        if (b == 8'h33) begin
            $display("Test 2: Multiple NBA PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: NBA to different signals
        test_count++;
        a <= 8'hFF;
        b <= 8'hEE;
        c <= 8'hDD;
        @(posedge clk);
        if (a == 8'hFF && b == 8'hEE && c == 8'hDD) begin
            $display("Test 3: Multiple signals PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: NBA with expression
        test_count++;
        a <= b + 8'h11;
        @(posedge clk);
        if (a == 8'hFF) begin
            $display("Test 4: NBA expression PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
