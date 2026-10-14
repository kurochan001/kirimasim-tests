/*
:name: test_timing_edge_cases
:description: Timing edge cases test
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.1 9.4.5 9.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_edge_cases.expected
*/
// IEEE 1800-2023: Timing edge cases test
// Tests various timing-related edge cases

module test_timing_edge_cases;
    int pass_count = 0;
    int test_count = 0;
    logic clk;
    logic [7:0] data;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test zero delay
    initial begin
        // Test 1: Zero delay (#0)
        test_count++;
        data = 8'h00;
        #0 data = 8'h01;
        if (data == 8'h01) begin
            pass_count++;
            $display("Test 1 PASS: zero delay (#0) works");
        end else begin
            $display("Test 1 FAIL: zero delay issue");
        end

        // Test 2: Consecutive zero delays
        test_count++;
        data = 8'h10;
        #0 data = 8'h11;
        #0 data = 8'h12;
        #0 data = 8'h13;
        if (data == 8'h13) begin
            pass_count++;
            $display("Test 2 PASS: consecutive zero delays");
        end else begin
            $display("Test 2 FAIL: consecutive zero delays issue");
        end

        // Test 3: Delay with expression
        test_count++;
        begin
            static int delay_val = 10;
            data = 8'h30;
            #(delay_val) data = 8'h31;
            if (data == 8'h31) begin
                pass_count++;
                $display("Test 3 PASS: delay with expression");
            end else begin
                $display("Test 3 FAIL: delay with expression issue");
            end
        end

        // Test 4: Intra-assignment delay
        test_count++;
        data = #5 8'hAA;
        if (data == 8'hAA) begin
            pass_count++;
            $display("Test 4 PASS: intra-assignment delay");
        end else begin
            $display("Test 4 FAIL: intra-assignment delay issue");
        end

        // Test 5: Event control after delay
        test_count++;
        @(posedge clk);
        data = 8'hBB;
        if (data == 8'hBB) begin
            pass_count++;
            $display("Test 5 PASS: event control timing");
        end else begin
            $display("Test 5 FAIL: event control timing issue");
        end

        repeat(2) @(posedge clk);

        $display("=== Timing Edge Cases Test Results ===");
        $display("Passed: %0d/%0d", pass_count, test_count);

        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end

endmodule
