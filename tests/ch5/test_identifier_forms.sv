/*
:name: test_identifier_forms
:description: Identifiers with underscores and mixed case, and generate block names
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6 27.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_identifier_forms.expected
*/
`timescale 1ns/1ps

module test_identifier_forms;
    // Test various identifier patterns
    logic signal_a;
    logic signal_b;
    logic _underscore_start;
    logic end_underscore_;
    logic CamelCase;
    logic ALLCAPS;

    // Generate with identifiers
    genvar i;
    generate
        for (i = 0; i < 3; i++) begin : gen_blk
            logic gen_sig;
        end
    endgenerate

    initial begin
        signal_a = 1;
        signal_b = 0;
        _underscore_start = 1;
        end_underscore_ = 0;
        CamelCase = 1;
        ALLCAPS = 0;

        // Check values
        if (!signal_a) $display("FAIL: signal_a");
        if (signal_b) $display("FAIL: signal_b");
        if (!_underscore_start) $display("FAIL: underscore");
        if (end_underscore_) $display("FAIL: end underscore");
        if (!CamelCase) $display("FAIL: CamelCase");
        if (ALLCAPS) $display("FAIL: ALLCAPS");

        // Generated identifiers
        gen_blk[0].gen_sig = 1;
        gen_blk[1].gen_sig = 0;
        gen_blk[2].gen_sig = 1;
        if (gen_blk[0].gen_sig !== 1'b1 || gen_blk[1].gen_sig !== 1'b0 || gen_blk[2].gen_sig !== 1'b1)
            $display("FAIL: generated identifiers");

        $display("TEST PASSED");
        $finish;
    end
endmodule
