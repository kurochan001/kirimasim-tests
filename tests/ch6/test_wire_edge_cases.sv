/*
:name: test_wire_edge_cases
:description: wire, tri, wand and wor nets with one and two drivers
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.1 6.6.3
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_wire_edge_cases.expected
*/
// IEEE 1800-2023 §6.6: Wire and net edge cases
// Tests for wire types and net behavior

module test_wire_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic driver_a, driver_b;
    wire w1;
    wire [7:0] w8;
    tri tri_wire;
    wand wand_wire;
    wor wor_wire;

    assign w1 = driver_a;
    assign w8 = {8{driver_a}};

    // Tri-state with multiple drivers
    assign tri_wire = driver_a ? 1'b1 : 1'bz;
    assign tri_wire = driver_b ? 1'b0 : 1'bz;

    // Wired AND
    assign wand_wire = driver_a;
    assign wand_wire = driver_b;

    // Wired OR
    assign wor_wire = driver_a;
    assign wor_wire = driver_b;

    initial begin
        driver_a = 0;
        driver_b = 0;
        #1;

        // Test 1: Wire basic
        test_count++;
        driver_a = 1;
        #1;
        if (w1 == 1) begin
            pass_count++;
            $display("Test 1 PASS: w1 = %b", w1);
        end else begin
            $display("Test 1 FAIL: Wire unexpected = %b", w1);
        end

        // Test 2: Wide wire
        test_count++;
        driver_a = 1;
        #1;
        if (w8 == 8'hFF) begin
            pass_count++;
            $display("Test 2 PASS: w8 = %h", w8);
        end else begin
            $display("Test 2 FAIL: Wide unexpected = %h", w8);
        end

        // Test 3: Wire zero
        test_count++;
        driver_a = 0;
        #1;
        if (w8 == 8'h00) begin
            pass_count++;
            $display("Test 3 PASS: w8 zero = %h", w8);
        end else begin
            $display("Test 3 FAIL: Zero unexpected = %h", w8);
        end

        // Test 4: Tri-state (both Z)
        test_count++;
        driver_a = 0;
        driver_b = 0;
        #1;
        if (tri_wire === 1'bz) begin
            pass_count++;
            $display("Test 4 PASS: Tri Z = %b", tri_wire);
        end else begin
            $display("Test 4 FAIL: Tri Z unexpected = %b", tri_wire);
        end

        // Test 5: Tri-state (A drives 1)
        test_count++;
        driver_a = 1;
        driver_b = 0;
        #1;
        if (tri_wire == 1) begin
            pass_count++;
            $display("Test 5 PASS: Tri 1 = %b", tri_wire);
        end else begin
            $display("Test 5 FAIL: Tri 1 unexpected = %b", tri_wire);
        end

        // Test 6: Tri-state (B drives 0)
        test_count++;
        driver_a = 0;
        driver_b = 1;
        #1;
        if (tri_wire == 0) begin
            pass_count++;
            $display("Test 6 PASS: Tri 0 = %b", tri_wire);
        end else begin
            $display("Test 6 FAIL: Tri 0 unexpected = %b", tri_wire);
        end

        // Test 7: Wand both 1
        test_count++;
        driver_a = 1;
        driver_b = 1;
        #1;
        if (wand_wire == 1) begin
            pass_count++;
            $display("Test 7 PASS: Wand 1&1 = %b", wand_wire);
        end else begin
            $display("Test 7 FAIL: Wand unexpected = %b", wand_wire);
        end

        // Test 8: Wand with 0
        test_count++;
        driver_a = 1;
        driver_b = 0;
        #1;
        if (wand_wire == 0) begin
            pass_count++;
            $display("Test 8 PASS: Wand 1&0 = %b", wand_wire);
        end else begin
            $display("Test 8 FAIL: Wand 0 unexpected = %b", wand_wire);
        end

        // Test 9: Wor both 0
        test_count++;
        driver_a = 0;
        driver_b = 0;
        #1;
        if (wor_wire == 0) begin
            pass_count++;
            $display("Test 9 PASS: Wor 0|0 = %b", wor_wire);
        end else begin
            $display("Test 9 FAIL: Wor 0 unexpected = %b", wor_wire);
        end

        // Test 10: Wor with 1
        test_count++;
        driver_a = 0;
        driver_b = 1;
        #1;
        if (wor_wire == 1) begin
            pass_count++;
            $display("Test 10 PASS: Wor 0|1 = %b", wor_wire);
        end else begin
            $display("Test 10 FAIL: Wor 1 unexpected = %b", wor_wire);
        end

        $display("=== Wire Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
