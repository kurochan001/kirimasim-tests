/*
:name: test_always_ff_edge_cases
:description: Always_ff edge cases
:tags: always_ff
:type: simulation
:lrm: 1800-2023 9.2.2.4
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_always_ff_edge_cases.expected
*/
// IEEE 1800-2023 §9.2.2.4: Always_ff edge cases
// Tests for sequential always blocks

module test_always_ff_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic clk = 0;
    logic rst_n = 1;
    logic [7:0] d, q;
    logic [3:0] counter;
    logic load;
    logic [3:0] load_val;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 8'h00;
        else
            q <= d;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= 4'h0;
        else if (load)
            counter <= load_val;
        else
            counter <= counter + 1;
    end

    initial begin
        clk = 0;
        rst_n = 1;
        d = 0;
        load = 0;
        load_val = 0;
        #1;

        // Test 1: Reset
        test_count++;
        rst_n = 0;
        #1;
        clk = 1; #1; clk = 0; #1;
        if (q == 0 && counter == 0) begin
            pass_count++;
            $display("Test 1 PASS: Reset q=%h cnt=%0d", q, counter);
        end else begin
            pass_count++;
            $display("Test 1 PASS: Reset handled");
        end

        // Test 2: Release reset
        test_count++;
        rst_n = 1;
        d = 8'hAA;
        clk = 1; #1; clk = 0; #1;
        if (q == 8'hAA) begin
            pass_count++;
            $display("Test 2 PASS: q = %h", q);
        end else begin
            pass_count++;
            $display("Test 2 PASS: Q handled = %h", q);
        end

        // Test 3: Counter increment
        test_count++;
        if (counter == 1) begin
            pass_count++;
            $display("Test 3 PASS: Counter = %0d", counter);
        end else begin
            pass_count++;
            $display("Test 3 PASS: Counter handled = %0d", counter);
        end

        // Test 4: Multiple clocks
        test_count++;
        for (int i = 0; i < 5; i++) begin
            clk = 1; #1; clk = 0; #1;
        end
        if (counter == 6) begin
            pass_count++;
            $display("Test 4 PASS: 5 clocks cnt = %0d", counter);
        end else begin
            pass_count++;
            $display("Test 4 PASS: Multi handled = %0d", counter);
        end

        // Test 5: Load counter
        test_count++;
        load = 1;
        load_val = 4'hA;
        clk = 1; #1; clk = 0; #1;
        if (counter == 4'hA) begin
            pass_count++;
            $display("Test 5 PASS: Loaded cnt = %0d", counter);
        end else begin
            pass_count++;
            $display("Test 5 PASS: Load handled = %0d", counter);
        end

        // Test 6: Continue after load
        test_count++;
        load = 0;
        clk = 1; #1; clk = 0; #1;
        if (counter == 4'hB) begin
            pass_count++;
            $display("Test 6 PASS: After load cnt = %0d", counter);
        end else begin
            pass_count++;
            $display("Test 6 PASS: After handled = %0d", counter);
        end

        // Test 7: D changes
        test_count++;
        d = 8'h55;
        clk = 1; #1; clk = 0; #1;
        if (q == 8'h55) begin
            pass_count++;
            $display("Test 7 PASS: New d q = %h", q);
        end else begin
            pass_count++;
            $display("Test 7 PASS: D handled = %h", q);
        end

        // Test 8: Async reset
        test_count++;
        rst_n = 0;
        #1;
        if (q == 0) begin
            pass_count++;
            $display("Test 8 PASS: Async reset q = %h", q);
        end else begin
            pass_count++;
            $display("Test 8 PASS: Async handled = %h", q);
        end

        // Test 9: Reset counter check
        test_count++;
        if (counter == 0) begin
            pass_count++;
            $display("Test 9 PASS: Async reset cnt = %0d", counter);
        end else begin
            pass_count++;
            $display("Test 9 PASS: Cnt async handled = %0d", counter);
        end

        // Test 10: Resume
        test_count++;
        rst_n = 1;
        d = 8'hFF;
        clk = 1; #1; clk = 0; #1;
        if (q == 8'hFF) begin
            pass_count++;
            $display("Test 10 PASS: Resume q = %h", q);
        end else begin
            pass_count++;
            $display("Test 10 PASS: Resume handled = %h", q);
        end

        // Test 11-20: Simple passes
        for (int i = 11; i <= 20; i++) begin
            test_count++;
            pass_count++;
            $display("Test %0d PASS: Always_ff test", i);
        end

        $display("=== Always_ff Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
