/*
:name: test_comb_generate_scope
:description: Test: Generate block scoping and conditional generate
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5 27.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_generate_scope.expected
*/
// Test: Generate block scoping and conditional generate
// Verifies IEEE 1800-2023 §27 generate constructs
module test;
    int pass_count = 0;

    parameter int WIDTH = 8;
    parameter bit ENABLE_PARITY = 1;

    // Generate if
    generate
        if (ENABLE_PARITY) begin : parity_gen
            logic parity;
            assign parity = ^WIDTH'(8'hA5);
        end
    endgenerate

    // Generate for
    generate
        for (genvar i = 0; i < 4; i++) begin : bit_gen
            logic [7:0] local_data;
            assign local_data = 8'(i * 10);
        end
    endgenerate

    initial begin
        #1;

        // Test 1: Generate if block access
        if (parity_gen.parity == 1'b0) begin
            $display("T1: PASS - generate if: parity = %b", parity_gen.parity);
            pass_count++;
        end else begin
            $display("T1: FAIL - generate if: parity = %b (expected 0)", parity_gen.parity);
        end

        // Test 2: Generate for block access [0]
        if (bit_gen[0].local_data == 0) begin
            $display("T2: PASS - generate for [0]: data = %0d", bit_gen[0].local_data);
            pass_count++;
        end else begin
            $display("T2: FAIL - generate for [0]: data = %0d (expected 0)", bit_gen[0].local_data);
        end

        // Test 3: Generate for block access [1]
        if (bit_gen[1].local_data == 10) begin
            $display("T3: PASS - generate for [1]: data = %0d", bit_gen[1].local_data);
            pass_count++;
        end else begin
            $display("T3: FAIL - generate for [1]: data = %0d (expected 10)", bit_gen[1].local_data);
        end

        // Test 4: Generate for block access [3]
        if (bit_gen[3].local_data == 30) begin
            $display("T4: PASS - generate for [3]: data = %0d", bit_gen[3].local_data);
            pass_count++;
        end else begin
            $display("T4: FAIL - generate for [3]: data = %0d (expected 30)", bit_gen[3].local_data);
        end

        // Test 5: Parameter used in generate
        if (WIDTH == 8) begin
            $display("T5: PASS - parameter WIDTH = %0d", WIDTH);
            pass_count++;
        end else begin
            $display("T5: FAIL - parameter WIDTH = %0d (expected 8)", WIDTH);
        end

        // Test 6: Conditional generate is active
        if (ENABLE_PARITY) begin
            $display("T6: PASS - ENABLE_PARITY = 1, parity_gen exists");
            pass_count++;
        end else begin
            $display("T6: FAIL - ENABLE_PARITY = 0");
        end

        $display("pass_count = %0d", pass_count);
        if (pass_count == 6)
            $display("PASS: test_comb_generate_scope");
        else
            $display("FAIL: test_comb_generate_scope (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
