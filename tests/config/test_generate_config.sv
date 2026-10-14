/*
:name: test_generate_config
:description: Configuration with generate blocks
:tags: config
:type: simulation
:lrm: 1800-2023 27.5
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_generate_config.expected
*/
// IEEE 1800-2023 §33: Configuration with generate blocks
// Tests configuration interacting with generate
// Verifies generated instance access

module configurable_block #(parameter int MODE = 0);
    logic [7:0] out;

    generate
        if (MODE == 0) begin : mode_a
            assign out = 8'hAA;
        end else if (MODE == 1) begin : mode_b
            assign out = 8'hBB;
        end else begin : mode_c
            assign out = 8'hCC;
        end
    endgenerate
endmodule

module test_generate_config;
    int pass_count = 0;
    int fail_count = 0;

    configurable_block #(.MODE(0)) block_a();
    configurable_block #(.MODE(1)) block_b();
    configurable_block #(.MODE(2)) block_c();

    initial begin
        $display("=== IEEE 1800-2023 §33: Generate Config ===");

        #1; // Allow continuous assignments to settle

        // Test 1: Mode 0 output
        if (block_a.out == 8'hAA) begin
            $display("PASS: MODE=0 produces 0xAA");
            pass_count++;
        end else begin
            $display("FAIL: MODE=0 output = %h", block_a.out);
            fail_count++;
        end

        // Test 2: Mode 1 output
        if (block_b.out == 8'hBB) begin
            $display("PASS: MODE=1 produces 0xBB");
            pass_count++;
        end else begin
            $display("FAIL: MODE=1 output = %h", block_b.out);
            fail_count++;
        end

        // Test 3: Mode 2 (else) output
        if (block_c.out == 8'hCC) begin
            $display("PASS: MODE=2 produces 0xCC");
            pass_count++;
        end else begin
            $display("FAIL: MODE=2 output = %h", block_c.out);
            fail_count++;
        end

        // Test 4: Different instances are independent
        if (block_a.out != block_b.out && block_b.out != block_c.out) begin
            $display("PASS: Instances are independent");
            pass_count++;
        end else begin
            $display("FAIL: Instances not independent");
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
