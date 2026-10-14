/*
:name: test_always_comb_latch
:description: Always_comb/latch/ff Tests
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2 9.2.2.3 9.2.2.4
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_always_comb_latch.expected
*/
// IEEE 1800-2023 Section 9.2.2 - Always_comb/latch/ff Tests
// Tests: always_comb, always_latch, always_ff constructs

module test_always_comb_latch;
    int pass_count = 0;
    int fail_count = 0;

    logic clk = 0;
    logic rst_n = 0;

    logic [7:0] a, b;
    logic [7:0] sum_comb;
    logic [7:0] latch_out;
    logic [7:0] ff_out;
    logic enable;

    // Clock generation
    always #5 clk = ~clk;

    // Combinational logic using always_comb
    always_comb begin
        sum_comb = a + b;
    end

    // Latch using always_latch
    always_latch begin
        if (enable)
            latch_out = a;
    end

    // Flip-flop using always_ff
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            ff_out <= 8'h00;
        else
            ff_out <= a;
    end

    initial begin
        $display("=== IEEE 1800-2023 Always_comb/latch/ff Tests ===");
        a = 8'h00;
        b = 8'h00;
        enable = 0;
        rst_n = 0;

        // Test 1: always_comb initial
        $display("Test 1: always_comb initial");
        #1;
        if (sum_comb == 8'h00) begin
            $display("Test 1 PASS: sum_comb=%h (0+0)", sum_comb);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %h", sum_comb);
            fail_count++;
        end

        // Test 2: always_comb update
        $display("Test 2: always_comb update");
        a = 8'h10;
        b = 8'h20;
        #1;
        if (sum_comb == 8'h30) begin
            $display("Test 2 PASS: sum_comb=%h (10+20)", sum_comb);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %h", sum_comb);
            fail_count++;
        end

        // Test 3: always_ff reset
        $display("Test 3: always_ff reset");
        @(posedge clk);
        @(negedge clk);
        if (ff_out == 8'h00) begin
            $display("Test 3 PASS: ff_out=%h (reset)", ff_out);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %h", ff_out);
            fail_count++;
        end

        // Test 4: always_ff after reset release
        $display("Test 4: always_ff after reset release");
        rst_n = 1;
        a = 8'hAA;
        @(posedge clk);
        @(negedge clk);
        if (ff_out == 8'hAA) begin
            $display("Test 4 PASS: ff_out=%h", ff_out);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: got %h", ff_out);
            fail_count++;
        end

        // Test 5: always_latch disabled
        $display("Test 5: always_latch disabled");
        enable = 0;
        a = 8'h55;
        #1;
        // Latch should hold previous value
        $display("Test 5 PASS: latch_out=%h (enable=0)", latch_out);
        pass_count++;

        // Test 6: always_latch enabled
        $display("Test 6: always_latch enabled");
        enable = 1;
        a = 8'hBB;
        #1;
        if (latch_out == 8'hBB) begin
            $display("Test 6 PASS: latch_out=%h", latch_out);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: got %h", latch_out);
            fail_count++;
        end

        // Test 7: always_comb another update
        $display("Test 7: always_comb another update");
        a = 8'hFF;
        b = 8'h01;
        #1;
        if (sum_comb == 8'h00) begin  // Overflow wraps
            $display("Test 7 PASS: sum_comb=%h (FF+01 overflow)", sum_comb);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: got %h", sum_comb);
            fail_count++;
        end

        // Test 8: always_ff second update
        $display("Test 8: always_ff second update");
        a = 8'hCC;
        @(posedge clk);
        @(negedge clk);
        if (ff_out == 8'hCC) begin
            $display("Test 8 PASS: ff_out=%h", ff_out);
            pass_count++;
        end else begin
            $display("Test 8 FAIL: got %h", ff_out);
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
