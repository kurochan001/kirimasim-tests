/*
:name: test_gen_assign_complex
:description: Generate block continuous assign with complex expressions
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.6 10.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_gen_assign_complex.expected
*/
// Generate block continuous assign with complex expressions
module test_gen_assign_complex;
    int pass_count = 0;

    parameter N = 4;
    logic [15:0] in_a[N];
    logic [15:0] in_b[N];
    logic [15:0] out_sum[N];
    logic [15:0] out_diff[N];
    logic out_gt[N];

    // Generate with multiple continuous assigns using localparams
    genvar gi;
    generate
        for (gi = 0; gi < N; gi++) begin : calc
            localparam int WEIGHT = gi + 1;
            localparam int BIAS = gi * 10;

            assign out_sum[gi] = in_a[gi] * WEIGHT + BIAS;
            assign out_diff[gi] = (in_a[gi] > in_b[gi]) ? in_a[gi] - in_b[gi] : 16'd0;
            assign out_gt[gi] = (in_a[gi] > BIAS);
        end
    endgenerate

    initial begin
        #1;

        // T1: Weighted sum with bias
        for (int i = 0; i < N; i++) begin
            in_a[i] = 16'd10;
            in_b[i] = 16'd5;
        end
        #1;
        // out_sum[0] = 10*1 + 0 = 10
        // out_sum[1] = 10*2 + 10 = 30
        // out_sum[2] = 10*3 + 20 = 50
        // out_sum[3] = 10*4 + 30 = 70
        if (out_sum[0] == 10 && out_sum[1] == 30 &&
            out_sum[2] == 50 && out_sum[3] == 70) begin
            $display("T1: PASS - weighted sum: %0d,%0d,%0d,%0d",
                out_sum[0], out_sum[1], out_sum[2], out_sum[3]);
            pass_count++;
        end else
            $display("T1: FAIL - %0d,%0d,%0d,%0d",
                out_sum[0], out_sum[1], out_sum[2], out_sum[3]);

        // T2: Conditional difference
        in_a[0] = 20; in_b[0] = 5;   // 20 > 5 → 15
        in_a[1] = 3;  in_b[1] = 10;  // 3 < 10 → 0
        in_a[2] = 50; in_b[2] = 50;  // 50 == 50 → 0
        in_a[3] = 100; in_b[3] = 1;  // 100 > 1 → 99
        #1;
        if (out_diff[0] == 15 && out_diff[1] == 0 &&
            out_diff[2] == 0 && out_diff[3] == 99) begin
            $display("T2: PASS - cond diff: %0d,%0d,%0d,%0d",
                out_diff[0], out_diff[1], out_diff[2], out_diff[3]);
            pass_count++;
        end else
            $display("T2: FAIL - %0d,%0d,%0d,%0d",
                out_diff[0], out_diff[1], out_diff[2], out_diff[3]);

        // T3: Comparison with BIAS
        // BIAS: [0]=0, [1]=10, [2]=20, [3]=30
        // in_a: 20, 3, 50, 100
        // out_gt: 20>0=1, 3>10=0, 50>20=1, 100>30=1
        if (out_gt[0] == 1 && out_gt[1] == 0 &&
            out_gt[2] == 1 && out_gt[3] == 1) begin
            $display("T3: PASS - compare: %0d,%0d,%0d,%0d",
                out_gt[0], out_gt[1], out_gt[2], out_gt[3]);
            pass_count++;
        end else
            $display("T3: FAIL - %0d,%0d,%0d,%0d",
                out_gt[0], out_gt[1], out_gt[2], out_gt[3]);

        // T4: Hierarchical access to localparams
        if (calc[0].WEIGHT == 1 && calc[1].WEIGHT == 2 &&
            calc[2].WEIGHT == 3 && calc[3].WEIGHT == 4) begin
            $display("T4: PASS - WEIGHT: %0d,%0d,%0d,%0d",
                calc[0].WEIGHT, calc[1].WEIGHT, calc[2].WEIGHT, calc[3].WEIGHT);
            pass_count++;
        end else
            $display("T4: FAIL");

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count == 4)
            $display("PASS: test_gen_assign_complex");
        else
            $display("FAIL: test_gen_assign_complex (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
