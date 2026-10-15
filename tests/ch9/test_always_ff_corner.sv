/*
:name: test_always_ff_corner
:description: always_ff with asynchronous and synchronous reset, enable, a counter and a shift register
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.4 4.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_always_ff_corner.expected
*/
// always_ff with asynchronous and synchronous reset, enable, a counter and a shift register
`timescale 1ns/1ps

module test_always_ff_corner;
    int pass_count = 0;
    int fail_count = 0;

    logic clk = 0;
    logic rst_n = 0;
    logic rst = 1;

    always #5 clk = ~clk;

    // Test signals
    logic [7:0] d_in;
    logic [7:0] q_out;
    logic [7:0] q_async_rst;
    logic [7:0] q_sync_rst;
    logic [7:0] q_enable;
    logic en;

    // Basic flip-flop
    always_ff @(posedge clk) begin
        q_out <= d_in;
    end

    // Flip-flop with async reset (active low)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q_async_rst <= 8'h00;
        else
            q_async_rst <= d_in;
    end

    // Flip-flop with sync reset (active high)
    always_ff @(posedge clk) begin
        if (rst)
            q_sync_rst <= 8'h00;
        else
            q_sync_rst <= d_in;
    end

    // Flip-flop with enable
    always_ff @(posedge clk) begin
        if (en)
            q_enable <= d_in;
    end

    // Counter
    logic [7:0] counter;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= 8'h00;
        else
            counter <= counter + 1;
    end

    // Shift register
    logic [7:0] shift_reg;
    logic shift_in;
    always_ff @(posedge clk) begin
        shift_reg <= {shift_reg[6:0], shift_in};
    end

    // Test 1: Basic flip-flop
    task test_basic_ff();
        d_in = 8'hAB;
        @(posedge clk);
        @(negedge clk);

        if (q_out == 8'hAB) begin
            $display("PASS: Basic always_ff works");
            pass_count++;
        end else begin
            $display("FAIL: Basic always_ff failed (q=%h)", q_out);
            fail_count++;
        end
    endtask

    // Test 2: Async reset
    task test_async_reset();
        d_in = 8'hFF;
        rst_n = 1;
        @(posedge clk);
        @(negedge clk);

        if (q_async_rst == 8'hFF) begin
            $display("PASS: Async reset FF captures data");
            pass_count++;
        end else begin
            $display("FAIL: Async reset data capture failed");
            fail_count++;
        end

        // Apply async reset
        rst_n = 0;
        #1;

        if (q_async_rst == 8'h00) begin
            $display("PASS: Async reset immediately clears FF");
            pass_count++;
        end else begin
            $display("FAIL: Async reset not immediate");
            fail_count++;
        end

        rst_n = 1;
    endtask

    // Test 3: Sync reset
    task test_sync_reset();
        rst = 0;
        d_in = 8'hCD;
        @(posedge clk);
        @(negedge clk);

        if (q_sync_rst == 8'hCD) begin
            $display("PASS: Sync reset FF captures data when rst=0");
            pass_count++;
        end else begin
            $display("FAIL: Sync reset data capture failed");
            fail_count++;
        end

        // Apply sync reset (takes effect at next clock)
        rst = 1;
        d_in = 8'hEE;
        @(posedge clk);
        @(negedge clk);

        if (q_sync_rst == 8'h00) begin
            $display("PASS: Sync reset clears FF at clock edge");
            pass_count++;
        end else begin
            $display("FAIL: Sync reset not working");
            fail_count++;
        end

        rst = 0;
    endtask

    // Test 4: Enable
    task test_enable();
        // Only the always_ff block may write q_enable (9.2.2.4). en has been 0
        // since time 0, so q_enable has never been written and is still x.
        en = 0;
        d_in = 8'h55;
        @(posedge clk);
        @(negedge clk);

        if (q_enable === 8'bx) begin
            $display("PASS: Enable=0 holds value");
            pass_count++;
        end else begin
            $display("FAIL: Enable=0 should hold");
            fail_count++;
        end

        en = 1;
        @(posedge clk);
        @(negedge clk);

        if (q_enable == 8'h55) begin
            $display("PASS: Enable=1 captures data");
            pass_count++;
        end else begin
            $display("FAIL: Enable=1 not capturing");
            fail_count++;
        end
    endtask

    // Test 5: Counter
    task test_counter();
        logic [7:0] start_val;

        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        @(negedge clk);
        start_val = counter;

        repeat (5) @(posedge clk);
        @(negedge clk);

        if (counter == start_val + 5) begin
            $display("PASS: Counter increments correctly");
            pass_count++;
        end else begin
            $display("FAIL: Counter = %0d, started at %0d", counter, start_val);
            fail_count++;
        end
    endtask

    // Test 6: Shift register
    task test_shift_register();
        // shift_in changes on falling edges, away from the rising edges that
        // sample it.
        shift_in = 1;
        repeat (4) @(posedge clk);
        @(negedge clk);
        shift_in = 0;
        repeat (4) @(posedge clk);
        @(negedge clk);

        if (shift_reg == 8'b11110000) begin
            $display("PASS: Shift register works");
            pass_count++;
        end else begin
            $display("FAIL: Shift register = %b", shift_reg);
            fail_count++;
        end
    endtask

    initial begin
        $display("=== always_ff Corner Cases Test ===");

        // Initialize
        d_in = 0;
        en = 0;
        shift_in = 0;

        // Reset sequence
        rst_n = 0;
        rst = 1;
        repeat (3) @(posedge clk);
        rst_n = 1;
        rst = 0;

        test_basic_ff();
        test_async_reset();
        test_sync_reset();
        test_enable();
        test_counter();
        test_shift_register();

        repeat (3) @(posedge clk);

        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
