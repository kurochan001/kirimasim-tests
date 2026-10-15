/*
:name: test_always_comb_latch_ff
:description: always_comb, always_latch and always_ff procedures (IEEE 1800-2023 Sections 9.2.2.2 to 9.2.2.4)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2 9.2.2.3 9.2.2.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_latch_ff.expected
*/
// Test for always_comb, always_latch and always_ff procedures
// IEEE 1800-2023 §9.2.2.2, §9.2.2.3 and §9.2.2.4

module test_always_comb_latch_ff;
    logic clk = 0;
    logic rst_n = 0;
    logic [7:0] counter_ff = 0;
    logic [7:0] mux_out;
    logic [1:0] sel = 0;
    logic [7:0] a = 8'hAA;
    logic [7:0] b = 8'hBB;
    logic [7:0] c = 8'hCC;
    logic [7:0] d = 8'hDD;
    logic latch_en = 0;
    logic [7:0] latch_data = 0;
    logic [7:0] latch_out;
    int pass_count = 0;
    int test_count = 0;

    // Clock generation
    always #5 clk = ~clk;

    // always_ff: Synchronous counter
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter_ff <= 8'h00;
        else
            counter_ff <= counter_ff + 1;
    end

    // always_comb: Combinational MUX
    always_comb begin
        case (sel)
            2'b00: mux_out = a;
            2'b01: mux_out = b;
            2'b10: mux_out = c;
            2'b11: mux_out = d;
        endcase
    end

    // always_latch: Level-sensitive latch
    always_latch begin
        if (latch_en)
            latch_out = latch_data;
    end

    initial begin
        // Wait for clock
        @(posedge clk);

        // Test 1: Reset counter
        test_count++;
        rst_n = 0;
        @(posedge clk);
        @(negedge clk);
        if (counter_ff == 0) begin
            $display("Test 1: Reset counter_ff=%0d PASS", counter_ff);
            pass_count++;
        end else begin
            $display("Test 1: Reset counter_ff=%0d FAIL", counter_ff);
        end

        // Test 2: Count up
        test_count++;
        rst_n = 1;
        repeat (5) @(posedge clk);
        @(negedge clk);
        if (counter_ff > 0) begin
            $display("Test 2: Count counter_ff=%0d PASS", counter_ff);
            pass_count++;
        end else begin
            $display("Test 2: Count counter_ff=%0d FAIL", counter_ff);
        end

        // Test 3: Combinational MUX sel=00
        test_count++;
        sel = 2'b00;
        #1;
        if (mux_out == 8'hAA) begin
            $display("Test 3: MUX sel=00 mux_out=%h PASS", mux_out);
            pass_count++;
        end else begin
            $display("Test 3: MUX sel=00 mux_out=%h FAIL", mux_out);
        end

        // Test 4: Combinational MUX sel=01
        test_count++;
        sel = 2'b01;
        #1;
        if (mux_out == 8'hBB) begin
            $display("Test 4: MUX sel=01 mux_out=%h PASS", mux_out);
            pass_count++;
        end else begin
            $display("Test 4: MUX sel=01 mux_out=%h FAIL", mux_out);
        end

        // Test 5: Combinational MUX sel=10
        test_count++;
        sel = 2'b10;
        #1;
        if (mux_out == 8'hCC) begin
            $display("Test 5: MUX sel=10 mux_out=%h PASS", mux_out);
            pass_count++;
        end else begin
            $display("Test 5: MUX sel=10 mux_out=%h FAIL", mux_out);
        end

        // Test 6: Combinational MUX sel=11
        test_count++;
        sel = 2'b11;
        #1;
        if (mux_out == 8'hDD) begin
            $display("Test 6: MUX sel=11 mux_out=%h PASS", mux_out);
            pass_count++;
        end else begin
            $display("Test 6: MUX sel=11 mux_out=%h FAIL", mux_out);
        end

        // Test 7: Latch transparent when en=1
        test_count++;
        latch_data = 8'h55;
        latch_en = 1;
        #1;
        if (latch_out == 8'h55) begin
            $display("Test 7: Latch en=1 latch_out=%h PASS", latch_out);
            pass_count++;
        end else begin
            $display("Test 7: Latch en=1 latch_out=%h FAIL", latch_out);
        end

        // Test 8: Latch holds when en=0
        test_count++;
        latch_en = 0;
        latch_data = 8'hFF;  // Change data
        #1;
        if (latch_out == 8'h55) begin  // Should still be 55
            $display("Test 8: Latch en=0 latch_out=%h PASS", latch_out);
            pass_count++;
        end else begin
            $display("Test 8: Latch en=0 latch_out=%h FAIL", latch_out);
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
