/*
:name: test_gen_ternary
:description: Generate block continuous assign with complex expressions
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 11.4.11 10.3.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_gen_ternary.expected
*/
// Generate block continuous assign with complex expressions
module test_gen_ternary;
    int pass_count = 0;

    parameter N = 4;
    logic [7:0] data_in[N];
    logic [7:0] data_out[N];
    logic enable[N];

    // Generate with ternary using localparam
    genvar gi;
    generate
        for (gi = 0; gi < N; gi++) begin : gen_mux
            localparam int THRESHOLD = gi * 50;

            // Complex expression using localparam in ternary
            assign data_out[gi] = (data_in[gi] > THRESHOLD) ? data_in[gi] : 8'd0;
        end
    endgenerate

    initial begin
        #1;

        // T1: All inputs at 100 - threshold test
        // THRESHOLD: [0]=0, [1]=50, [2]=100, [3]=150
        for (int i = 0; i < N; i++) data_in[i] = 8'd100;
        for (int i = 0; i < N; i++) enable[i] = 1'b1;
        #1;
        // data_in[0]=100 > 0 → 100
        // data_in[1]=100 > 50 → 100
        // data_in[2]=100 > 100 → false → 0
        // data_in[3]=100 > 150 → false → 0
        if (data_out[0] == 100 && data_out[1] == 100 &&
            data_out[2] == 0 && data_out[3] == 0) begin
            $display("T1: PASS - threshold: %0d,%0d,%0d,%0d",
                data_out[0], data_out[1], data_out[2], data_out[3]);
            pass_count++;
        end else
            $display("T1: FAIL - %0d,%0d,%0d,%0d",
                data_out[0], data_out[1], data_out[2], data_out[3]);

        // T2: All inputs at 200
        for (int i = 0; i < N; i++) data_in[i] = 8'd200;
        #1;
        if (data_out[0] == 200 && data_out[1] == 200 &&
            data_out[2] == 200 && data_out[3] == 200) begin
            $display("T2: PASS - all pass: %0d,%0d,%0d,%0d",
                data_out[0], data_out[1], data_out[2], data_out[3]);
            pass_count++;
        end else
            $display("T2: FAIL - %0d,%0d,%0d,%0d",
                data_out[0], data_out[1], data_out[2], data_out[3]);

        // T3: Input at 25 - only channel 0 passes
        for (int i = 0; i < N; i++) data_in[i] = 8'd25;
        #1;
        if (data_out[0] == 25 && data_out[1] == 0 &&
            data_out[2] == 0 && data_out[3] == 0) begin
            $display("T3: PASS - only [0] passes: %0d,%0d,%0d,%0d",
                data_out[0], data_out[1], data_out[2], data_out[3]);
            pass_count++;
        end else
            $display("T3: FAIL - %0d,%0d,%0d,%0d",
                data_out[0], data_out[1], data_out[2], data_out[3]);

        // T4: Hierarchical THRESHOLD access
        if (gen_mux[0].THRESHOLD == 0 && gen_mux[1].THRESHOLD == 50 &&
            gen_mux[2].THRESHOLD == 100 && gen_mux[3].THRESHOLD == 150) begin
            $display("T4: PASS - THRESHOLD: %0d,%0d,%0d,%0d",
                gen_mux[0].THRESHOLD, gen_mux[1].THRESHOLD,
                gen_mux[2].THRESHOLD, gen_mux[3].THRESHOLD);
            pass_count++;
        end else
            $display("T4: FAIL");

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count >= 3)
            $display("PASS: test_gen_ternary");
        else
            $display("FAIL: test_gen_ternary (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
