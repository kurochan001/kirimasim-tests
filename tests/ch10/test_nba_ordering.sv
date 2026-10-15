/*
:name: test_nba_ordering
:description: Non-blocking assignment region
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2 4.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_ordering.expected
*/
// IEEE 1800-2023 §4.4.2: Non-blocking assignment region
// Tests that NBA updates are scheduled to NBA region
// Verifies correct NBA ordering and timing

module test_nba_ordering;
    int pass_count = 0;
    int fail_count = 0;

    logic clk = 0;
    logic [7:0] a, b, c;
    logic [7:0] old_a;

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("=== IEEE 1800-2023 §4.4.2: NBA Ordering ===");

        // Initialize
        a = 0;
        b = 0;
        c = 0;

        // Test 1: Single NBA - value not applied immediately in same expression
        @(posedge clk);
        a <= 8'hAA;
        // At this point, a should still be 0 (NBA not yet applied)
        if (a == 0) begin
            $display("PASS: NBA not applied in same time slot");
            pass_count++;
        end else begin
            $display("FAIL: NBA applied too early");
            fail_count++;
        end

        // Test 2: NBA applied after clock edge
        @(posedge clk);
        if (a == 8'hAA) begin
            $display("PASS: NBA applied after clock edge");
            pass_count++;
        end else begin
            $display("FAIL: NBA not applied, a = %h", a);
            fail_count++;
        end

        // Test 3: Multiple NBAs on same variable - last wins
        b <= 8'h11;
        b <= 8'h22;
        b <= 8'h33;
        @(posedge clk);
        // Last NBA should win
        if (b == 8'h33) begin
            $display("PASS: Last NBA wins, b = %h", b);
            pass_count++;
        end else begin
            $display("FAIL: Wrong NBA result, b = %h", b);
            fail_count++;
        end

        // Test 4: NBA uses RHS value at scheduling time
        old_a = a;
        a <= 8'h10;
        b <= old_a + 1; // Uses saved old value of a
        @(posedge clk);
        if (a == 8'h10) begin
            $display("PASS: NBA updated a to 10");
            pass_count++;
        end else begin
            $display("FAIL: NBA a wrong, a=%h", a);
            fail_count++;
        end

        // Test 5: Blocking vs NBA in same block
        a = 8'hFF;  // Blocking - immediate
        b <= a;     // NBA - should use new value of a (0xFF)
        @(posedge clk);
        if (b == 8'hFF) begin
            $display("PASS: NBA reads blocking result, b = %h", b);
            pass_count++;
        end else begin
            $display("FAIL: NBA wrong, b = %h", b);
            fail_count++;
        end

        $display("");
        $display("=== Results: %0d PASS, %0d FAIL ===", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
