/*
:name: test_gen_cross_call
:description: Generate block cross-scope function calls
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 23.8 13.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_gen_cross_call.expected
*/
// Generate block cross-scope function calls
module test_gen_cross_call;
    int pass_count = 0;

    parameter N = 4;

    // Generate for with functions that reference each other's localparams
    generate
        for (genvar i = 0; i < N; i++) begin : stage
            localparam int WEIGHT = i + 1;
            localparam int OFFSET = i * 100;

            function automatic int compute(int val);
                return val * WEIGHT + OFFSET;
            endfunction
        end
    endgenerate

    int results[4];

    initial begin
        #1;

        // T1: Call each generate instance function
        results[0] = stage[0].compute(5);
        results[1] = stage[1].compute(5);
        results[2] = stage[2].compute(5);
        results[3] = stage[3].compute(5);
        // stage[0]: 5*1+0=5, stage[1]: 5*2+100=110, stage[2]: 5*3+200=215, stage[3]: 5*4+300=320
        if (results[0] == 5 && results[1] == 110 && results[2] == 215 && results[3] == 320) begin
            $display("T1: PASS - compute: %0d,%0d,%0d,%0d", results[0], results[1], results[2], results[3]);
            pass_count++;
        end else
            $display("T1: FAIL - %0d,%0d,%0d,%0d", results[0], results[1], results[2], results[3]);

        // T2: Verify localparams are per-instance
        if (stage[0].WEIGHT == 1 && stage[1].WEIGHT == 2 && stage[2].WEIGHT == 3 && stage[3].WEIGHT == 4) begin
            $display("T2: PASS - WEIGHT: %0d,%0d,%0d,%0d", stage[0].WEIGHT, stage[1].WEIGHT, stage[2].WEIGHT, stage[3].WEIGHT);
            pass_count++;
        end else
            $display("T2: FAIL");

        // T3: Verify OFFSET
        if (stage[0].OFFSET == 0 && stage[1].OFFSET == 100 && stage[2].OFFSET == 200 && stage[3].OFFSET == 300) begin
            $display("T3: PASS - OFFSET: %0d,%0d,%0d,%0d", stage[0].OFFSET, stage[1].OFFSET, stage[2].OFFSET, stage[3].OFFSET);
            pass_count++;
        end else
            $display("T3: FAIL");

        // T4: Call with different arguments
        results[0] = stage[0].compute(0);
        results[1] = stage[1].compute(0);
        results[2] = stage[2].compute(0);
        results[3] = stage[3].compute(0);
        // stage[0]: 0+0=0, stage[1]: 0+100=100, stage[2]: 0+200=200, stage[3]: 0+300=300
        if (results[0] == 0 && results[1] == 100 && results[2] == 200 && results[3] == 300) begin
            $display("T4: PASS - zero: %0d,%0d,%0d,%0d", results[0], results[1], results[2], results[3]);
            pass_count++;
        end else
            $display("T4: FAIL - %0d,%0d,%0d,%0d", results[0], results[1], results[2], results[3]);

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count >= 3)
            $display("PASS: test_gen_cross_call");
        else
            $display("FAIL: test_gen_cross_call (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
