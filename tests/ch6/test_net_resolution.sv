/*
:name: test_net_resolution
:description: Net Resolution Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.1 6.6.3
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_resolution.expected
*/
// IEEE 1800-2023 Sections 6.6.1 and 6.6.3 - Net Resolution Tests
// Tests: Wire, wand, wor resolution

module test_net_resolution;
    int pass_count = 0;
    int fail_count = 0;

    // Wire with multiple drivers
    wire w1;
    assign w1 = 1'b1;

    // Wand (wired AND)
    wand wand1;
    assign wand1 = 1'b1;
    assign wand1 = 1'b1;

    wire wand2_a = 1'b1;
    wire wand2_b = 1'b0;
    wand wand2;
    assign wand2 = wand2_a;
    assign wand2 = wand2_b;

    // Wor (wired OR)
    wor wor1;
    assign wor1 = 1'b0;
    assign wor1 = 1'b0;

    wire wor2_a = 1'b0;
    wire wor2_b = 1'b1;
    wor wor2;
    assign wor2 = wor2_a;
    assign wor2 = wor2_b;

    // Simple wire
    wire simple_wire;
    assign simple_wire = 1'b1;

    // Tri-state
    wire tri_wire;
    assign tri_wire = 1'bz;

    initial begin
        $display("=== IEEE 1800-2023 Net Resolution Tests ===");

        // Test 1: Simple wire
        $display("Test 1: Simple wire");
        #1;
        if (w1 == 1'b1) begin
            $display("Test 1 PASS: wire w1=%b", w1);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %b", w1);
            fail_count++;
        end

        // Test 2: Wand with both 1
        $display("Test 2: Wand with both 1");
        if (wand1 == 1'b1) begin
            $display("Test 2 PASS: wand 1&1=%b", wand1);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %b", wand1);
            fail_count++;
        end

        // Test 3: Wand with 1 and 0
        $display("Test 3: Wand with 1 and 0");
        if (wand2 == 1'b0) begin
            $display("Test 3 PASS: wand 1&0=%b", wand2);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %b", wand2);
            fail_count++;
        end

        // Test 4: Wor with both 0
        $display("Test 4: Wor with both 0");
        if (wor1 == 1'b0) begin
            $display("Test 4 PASS: wor 0|0=%b", wor1);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: got %b", wor1);
            fail_count++;
        end

        // Test 5: Wor with 0 and 1
        $display("Test 5: Wor with 0 and 1");
        if (wor2 == 1'b1) begin
            $display("Test 5 PASS: wor 0|1=%b", wor2);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: got %b", wor2);
            fail_count++;
        end

        // Test 6: Simple wire value
        $display("Test 6: Simple wire value");
        if (simple_wire == 1'b1) begin
            $display("Test 6 PASS: simple_wire=%b", simple_wire);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: got %b", simple_wire);
            fail_count++;
        end

        // Test 7: Tri-state wire
        $display("Test 7: Tri-state wire");
        if (tri_wire === 1'bz) begin
            $display("Test 7 PASS: tri_wire=%b (high-Z)", tri_wire);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: got %b", tri_wire);
            fail_count++;
        end

        // Test 8: Wire comparison
        $display("Test 8: Wire comparison");
        if (w1 == simple_wire) begin
            $display("Test 8 PASS: w1==simple_wire");
            pass_count++;
        end else begin
            $display("Test 8 FAIL");
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
