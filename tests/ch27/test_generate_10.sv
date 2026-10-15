/*
:name: test_generate_10
:description: Chapter 27: Generate constructs
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_10.expected
*/
// IEEE 1800-2023 Chapter 27: Generate constructs
// §27.3 Generate constructs

module test_generate;
    int test_count;
    int pass_count;

    // §27.4 Loop generate
    genvar i;
    logic [3:0] gen_signals[4];

    generate
        for (i = 0; i < 4; i++) begin : gen_loop
            assign gen_signals[i] = i;
        end
    endgenerate

    // §27.5 Conditional generate
    parameter USE_ALT = 1;

    generate
        if (USE_ALT) begin : alt_block
            logic [7:0] alt_data;
            assign alt_data = 8'hAA;
        end else begin : main_block
            logic [7:0] main_data;
            assign main_data = 8'hBB;
        end
    endgenerate

    initial begin
        test_count = 0;
        pass_count = 0;

        #1;  // Wait for generates to elaborate

        // Test 1: Loop generate signal 0
        test_count++;
        if (gen_signals[0] == 0) pass_count++;
        else $display("FAIL: gen_signals[0] = %0d (expected 0)", gen_signals[0]);

        // Test 2: Loop generate signal 1
        test_count++;
        if (gen_signals[1] == 1) pass_count++;
        else $display("FAIL: gen_signals[1] = %0d (expected 1)", gen_signals[1]);

        // Test 3: Loop generate signal 3
        test_count++;
        if (gen_signals[3] == 3) pass_count++;
        else $display("FAIL: gen_signals[3] = %0d (expected 3)", gen_signals[3]);

        // Test 4: Conditional generate (USE_ALT = 1)
        test_count++;
        if (alt_block.alt_data == 8'hAA) pass_count++;
        else $display("FAIL: alt_data = 0x%0h (expected 0xAA)", alt_block.alt_data);

        $display("Chapter 27 Generate: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
