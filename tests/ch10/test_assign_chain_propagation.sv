/*
:name: test_assign_chain_propagation
:description: A chain of continuous assignments settles after each change of its source
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_chain_propagation.expected
*/
// A chain of continuous assignments settles after each change of its source
// IEEE 1800-2023 §10.3

module test_assign_chain_propagation;
    logic [7:0] a, b, c, d, e;
    int pass_count = 0;
    int test_count = 0;

    // Chain of dependencies
    assign b = a + 1;
    assign c = b + 1;
    assign d = c + 1;
    assign e = d + 1;

    initial begin
        // Test 1: Initial propagation
        test_count++;
        a = 8'h00;
        #1;
        if (e == 8'h04) begin
            $display("Test 1: Chain propagation PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL e=%h", e);
        end

        // Test 2: Update propagation
        test_count++;
        a = 8'h10;
        #1;
        if (e == 8'h14) begin
            $display("Test 2: Update propagation PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL e=%h", e);
        end

        // Test 3: Multiple updates
        test_count++;
        for (int i = 0; i < 5; i++) begin
            a = i;
            #1;
        end
        if (e == 8'h08) begin
            $display("Test 3: Multiple updates PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL e=%h", e);
        end

        // Test 4: Max value
        test_count++;
        a = 8'hFB;
        #1;
        if (e == 8'hFF) begin
            $display("Test 4: Max value PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL e=%h", e);
        end

        // Test 5: Overflow
        test_count++;
        a = 8'hFC;
        #1;
        if (e == 8'h00) begin
            $display("Test 5: Overflow PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL e=%h", e);
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
