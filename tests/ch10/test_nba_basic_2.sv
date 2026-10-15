/*
:name: test_nba_basic_2
:description: Non-Blocking Assignment (§10.4.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_basic_2.expected
*/
// IEEE 1800-2023 Non-Blocking Assignment (§10.4.2)
// Tests basic non-blocking assignment behavior

module test_nba_basic;
    logic clk = 0;
    logic [7:0] a, b, c;
    int pass_count = 0;
    int fail_count = 0;

    always #5 clk = ~clk;

    initial begin
        a = 8'h00;
        b = 8'h00;
        c = 8'h00;

        @(posedge clk);

        // Test 1: NBA doesn't take effect until end of time step
        a <= 8'hAA;
        if (a == 8'h00) begin
            $display("PASS: NBA value not yet visible (a = 0x%02X)", a);
            pass_count++;
        end else begin
            $display("FAIL: NBA value visible prematurely");
            fail_count++;
        end

        @(posedge clk);

        // Test 2: NBA value visible after next time step
        if (a == 8'hAA) begin
            $display("PASS: NBA value now visible (a = 0x%02X)", a);
            pass_count++;
        end else begin
            $display("FAIL: NBA value not updated");
            fail_count++;
        end

        // Test 3: Multiple NBAs to same variable - last wins
        b <= 8'h11;
        b <= 8'h22;
        b <= 8'h33;

        @(posedge clk);

        if (b == 8'h33) begin
            $display("PASS: Last NBA wins (b = 0x%02X)", b);
            pass_count++;
        end else begin
            $display("FAIL: Last NBA did not win, b = 0x%02X", b);
            fail_count++;
        end

        // Test 4: NBA swap without temporary
        a = 8'h55;
        b = 8'hAA;
        a <= b;
        b <= a;

        @(posedge clk);

        if (a == 8'hAA && b == 8'h55) begin
            $display("PASS: NBA swap works (a=0x%02X, b=0x%02X)", a, b);
            pass_count++;
        end else begin
            $display("FAIL: NBA swap failed (a=0x%02X, b=0x%02X)", a, b);
            fail_count++;
        end

        $display("");
        $display("=== NBA Basic Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
