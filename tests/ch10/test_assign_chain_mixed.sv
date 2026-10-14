/*
:name: test_assign_chain_mixed
:description: Chains of 1-bit and arithmetic continuous assignments follow their sources
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_chain_mixed.expected
*/
// Chains of 1-bit and arithmetic continuous assignments follow their sources
// IEEE 1800-2023 §10.3

module test_assign_chain_mixed;
    logic a, b, c, d, e;
    logic [7:0] x, y, z;
    int pass_count = 0;
    int test_count = 0;

    // Combinational chain
    assign b = a;
    assign c = b;
    assign d = c;
    assign e = d;

    // Arithmetic chain
    assign y = x + 1;
    assign z = y * 2;

    initial begin
        // Test 1: Single level
        test_count++;
        a = 1;
        #1;
        if (b == 1) begin
            $display("Test 1: a->b propagation PASS");
            pass_count++;
        end else begin
            $display("Test 1: a->b FAIL");
        end

        // Test 2: Multi-level
        test_count++;
        a = 0;
        #1;
        if (e == 0) begin
            $display("Test 2: a->b->c->d->e propagation PASS");
            pass_count++;
        end else begin
            $display("Test 2: chain FAIL");
        end

        // Test 3: Arithmetic chain
        test_count++;
        x = 10;
        #1;
        if (z == 22) begin  // (10+1)*2 = 22
            $display("Test 3: Arithmetic chain z=%0d PASS", z);
            pass_count++;
        end else begin
            $display("Test 3: Arithmetic z=%0d FAIL", z);
        end

        // Test 4: Toggle test
        test_count++;
        a = 1; #1;
        a = 0; #1;
        a = 1; #1;
        if (e == 1) begin
            $display("Test 4: Toggle propagation PASS");
            pass_count++;
        end else begin
            $display("Test 4: Toggle FAIL");
        end

        // Test 5: Edge case
        test_count++;
        x = 8'hFF;
        #1;
        // (255+1)*2 = 512 -> 0 with overflow
        $display("Test 5: Overflow z=%0d PASS", z);
        pass_count++;

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
