/*
:name: test_always_ff_async
:description: always_ff async reset
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.4 4.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_ff_async.expected
*/
// always_ff async reset
// Verifies asynchronous reset behavior in flip-flops

module test_always_ff_async;
    logic clk, rst_n;
    logic [7:0] d, q;
    logic [3:0] counter;
    logic set_n;
    logic [7:0] q_set;
    int pass_count = 0;
    int fail_count = 0;

    // Scenario 1: Async active-low reset
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 8'h00;
        else
            q <= d;
    end

    // Scenario 2: Counter with async reset
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= 4'h0;
        else
            counter <= counter + 1;
    end

    // Scenario 3: Async set
    always_ff @(posedge clk or negedge set_n) begin
        if (!set_n)
            q_set <= 8'hFF;
        else
            q_set <= d;
    end

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Assert the reset at time 1, when the always_ff blocks are surely
        // waiting for its falling edge; at time 0 they may not be yet (4.7).
        rst_n = 1;
        set_n = 1;
        d = 8'h00;
        #1;
        rst_n = 0;

        // Test 1: Verify reset takes effect immediately
        #1;
        if (q === 8'h00 && counter === 4'h0) begin
            $display("PASS: Scenario 1 - Async reset initial state");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 1 - q=0x%h, counter=%0d (expected 0, 0)", q, counter);
            fail_count++;
        end

        // Release reset
        rst_n = 1;
        @(posedge clk);

        // Test 2: Normal operation after reset release
        d = 8'hAB;
        @(posedge clk);
        #1;
        if (q === 8'hAB) begin
            $display("PASS: Scenario 2 - Normal operation after reset");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 2 - q=0x%h (expected 0xAB)", q);
            fail_count++;
        end

        // Test 3: Async reset mid-operation (without clock edge)
        d = 8'hCD;
        #2;
        rst_n = 0;
        #1;
        if (q === 8'h00) begin
            $display("PASS: Scenario 3 - Async reset without clock edge");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 3 - q=0x%h (expected 0x00)", q);
            fail_count++;
        end

        // Test 4: Counter reset
        if (counter === 4'h0) begin
            $display("PASS: Scenario 4 - Counter reset to 0");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 4 - counter=%0d (expected 0)", counter);
            fail_count++;
        end

        // Release reset and run counter
        rst_n = 1;
        repeat(3) @(posedge clk);
        #1;

        // Test 5: Counter incremented
        if (counter === 4'h3) begin
            $display("PASS: Scenario 5 - Counter incremented to %0d", counter);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 5 - counter=%0d (expected 3)", counter);
            fail_count++;
        end

        // Test 6: Async set
        set_n = 0;
        #1;
        if (q_set === 8'hFF) begin
            $display("PASS: Scenario 6 - Async set to 0xFF");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 6 - q_set=0x%h (expected 0xFF)", q_set);
            fail_count++;
        end

        // Summary
        $display("always_ff async reset: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS");
        else $display("FAIL");
        $finish;
    end
endmodule
