/*
:name: test_nba_assignments
:description: Non-blocking Assignments
:tags: assignments
:type: simulation
:lrm: 1800-2023 10.4.2
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_nba_assignments.expected
*/
// IEEE 1800-2023 §10.4.2 Non-blocking Assignments
// Tests non-blocking assignment behavior

`timescale 1ns/1ps

module test_nba_assignments;
    int pass_count = 0;
    int fail_count = 0;

    logic clk = 0;
    logic [7:0] a, b, c;
    logic [7:0] arr[4];
    int x, y, z;

    // Generate clock
    initial begin
        repeat (20) begin
            #5 clk = ~clk;
        end
    end

    initial begin
        // Test 1: Basic NBA ordering
        a = 8'd0;
        b = 8'd0;
        @(posedge clk);
        a <= 8'd10;
        b <= a;  // Should get OLD value of a (0)
        @(posedge clk);
        if (a == 8'd10 && b == 8'd0) begin
            $display("PASS: NBA ordering - b got old value of a");
            pass_count++;
        end else begin
            $display("FAIL: NBA ordering - a=%0d, b=%0d", a, b);
            fail_count++;
        end

        // Test 2: Multiple NBA to same variable
        x = 0;
        @(posedge clk);
        x <= 1;
        x <= 2;
        x <= 3;  // Last one wins
        @(posedge clk);
        if (x == 3) begin
            $display("PASS: Multiple NBA - last value wins");
            pass_count++;
        end else begin
            $display("FAIL: Multiple NBA - x=%0d", x);
            fail_count++;
        end

        // Test 3: NBA with delay
        y = 0;
        @(posedge clk);
        y <= #2 100;
        @(posedge clk);
        // After clk edge, y should be updated by now
        if (y == 100) begin
            $display("PASS: NBA with intra-assignment delay");
            pass_count++;
        end else begin
            $display("FAIL: NBA with delay - y=%0d", y);
            fail_count++;
        end

        // Test 4: NBA to array element
        arr[0] = 8'd0;
        arr[1] = 8'd0;
        @(posedge clk);
        arr[0] <= 8'd55;
        arr[1] <= 8'd66;
        @(posedge clk);
        if (arr[0] == 8'd55 && arr[1] == 8'd66) begin
            $display("PASS: NBA to array elements");
            pass_count++;
        end else begin
            $display("FAIL: NBA to array - arr[0]=%0d, arr[1]=%0d", arr[0], arr[1]);
            fail_count++;
        end

        // Test 5: Blocking followed by NBA
        z = 5;
        @(posedge clk);
        z = 10;     // Blocking - immediate
        z <= 20;    // NBA - deferred
        // z should still be 10 in this time step
        if (z == 10) begin
            $display("PASS: Blocking value visible before NBA takes effect");
            pass_count++;
        end else begin
            $display("FAIL: Blocking/NBA mix - z=%0d (expected 10)", z);
            fail_count++;
        end
        @(posedge clk);
        if (z == 20) begin
            $display("PASS: NBA takes effect after time step");
            pass_count++;
        end else begin
            $display("FAIL: NBA effect - z=%0d (expected 20)", z);
            fail_count++;
        end

        $display("");
        $display("=== Non-blocking Assignment Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
