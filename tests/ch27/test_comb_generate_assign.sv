/*
:name: test_comb_generate_assign
:description: Generate for loop continuous assignment tests
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_generate_assign.expected
*/
// IEEE 1800-2023 §27.4: Generate for loop continuous assignment tests
// used base name "data", so dirty marking missed the indexed dependency.
module test_comb_generate_assign;
    int pass_count = 0;
    int fail_count = 0;

    // T1: Basic generate for loop with array element assign
    parameter N1 = 4;
    logic [7:0] data1[N1];
    logic [7:0] result1[N1];

    genvar i;
    generate
        for (i = 0; i < N1; i++) begin : gen_add
            assign result1[i] = data1[i] + 8'd1;
        end
    endgenerate

    // T2: Generate with bitwise operations
    parameter N2 = 3;
    logic [7:0] a2[N2];
    logic [7:0] b2[N2];
    logic [7:0] xor_result[N2];

    generate
        for (genvar j = 0; j < N2; j++) begin : gen_xor
            assign xor_result[j] = a2[j] ^ b2[j];
        end
    endgenerate

    // T3: Generate with concatenation in RHS
    logic [3:0] hi3[2];
    logic [3:0] lo3[2];
    logic [7:0] combined3[2];

    generate
        for (genvar k = 0; k < 2; k++) begin : gen_concat
            assign combined3[k] = {hi3[k], lo3[k]};
        end
    endgenerate

    // T4: Generate with conditional expression
    logic sel4[2];
    logic [7:0] true_val4[2];
    logic [7:0] false_val4[2];
    logic [7:0] mux_result4[2];

    generate
        for (genvar m = 0; m < 2; m++) begin : gen_mux
            assign mux_result4[m] = sel4[m] ? true_val4[m] : false_val4[m];
        end
    endgenerate

    // T5: Generate with value update after initial assignment
    logic [7:0] data5[2];
    logic [7:0] result5[2];

    generate
        for (genvar n = 0; n < 2; n++) begin : gen_update
            assign result5[n] = data5[n] * 2;
        end
    endgenerate

    initial begin
        // T1: Basic add
        data1[0] = 8'd10;
        data1[1] = 8'd20;
        data1[2] = 8'd30;
        data1[3] = 8'd40;
        #1;

        if (result1[0] == 8'd11) pass_count++;
        else begin fail_count++; $display("T1a FAIL: result1[0]=%0d expected 11", result1[0]); end

        if (result1[1] == 8'd21) pass_count++;
        else begin fail_count++; $display("T1b FAIL: result1[1]=%0d expected 21", result1[1]); end

        if (result1[2] == 8'd31) pass_count++;
        else begin fail_count++; $display("T1c FAIL: result1[2]=%0d expected 31", result1[2]); end

        if (result1[3] == 8'd41) pass_count++;
        else begin fail_count++; $display("T1d FAIL: result1[3]=%0d expected 41", result1[3]); end

        // T1e: Update and verify re-evaluation
        data1[2] = 8'd100;
        #1;
        if (result1[2] == 8'd101) pass_count++;
        else begin fail_count++; $display("T1e FAIL: result1[2]=%0d expected 101", result1[2]); end

        // T2: XOR
        a2[0] = 8'hAA; b2[0] = 8'h55;
        a2[1] = 8'hFF; b2[1] = 8'hFF;
        a2[2] = 8'h0F; b2[2] = 8'hF0;
        #1;

        if (xor_result[0] == 8'hFF) pass_count++;
        else begin fail_count++; $display("T2a FAIL: xor_result[0]=%h expected FF", xor_result[0]); end

        if (xor_result[1] == 8'h00) pass_count++;
        else begin fail_count++; $display("T2b FAIL: xor_result[1]=%h expected 00", xor_result[1]); end

        if (xor_result[2] == 8'hFF) pass_count++;
        else begin fail_count++; $display("T2c FAIL: xor_result[2]=%h expected FF", xor_result[2]); end

        // T3: Concatenation
        hi3[0] = 4'hA; lo3[0] = 4'h5;
        hi3[1] = 4'hF; lo3[1] = 4'h0;
        #1;

        if (combined3[0] == 8'hA5) pass_count++;
        else begin fail_count++; $display("T3a FAIL: combined3[0]=%h expected A5", combined3[0]); end

        if (combined3[1] == 8'hF0) pass_count++;
        else begin fail_count++; $display("T3b FAIL: combined3[1]=%h expected F0", combined3[1]); end

        // T4: Conditional
        sel4[0] = 1'b1; true_val4[0] = 8'd42; false_val4[0] = 8'd99;
        sel4[1] = 1'b0; true_val4[1] = 8'd42; false_val4[1] = 8'd99;
        #1;

        if (mux_result4[0] == 8'd42) pass_count++;
        else begin fail_count++; $display("T4a FAIL: mux_result4[0]=%0d expected 42", mux_result4[0]); end

        if (mux_result4[1] == 8'd99) pass_count++;
        else begin fail_count++; $display("T4b FAIL: mux_result4[1]=%0d expected 99", mux_result4[1]); end

        // T5: Multiply with update
        data5[0] = 8'd5;
        data5[1] = 8'd10;
        #1;

        if (result5[0] == 8'd10) pass_count++;
        else begin fail_count++; $display("T5a FAIL: result5[0]=%0d expected 10", result5[0]); end

        if (result5[1] == 8'd20) pass_count++;
        else begin fail_count++; $display("T5b FAIL: result5[1]=%0d expected 20", result5[1]); end

        // T5c: Update and verify
        data5[0] = 8'd50;
        #1;
        if (result5[0] == 8'd100) pass_count++;
        else begin fail_count++; $display("T5c FAIL: result5[0]=%0d expected 100", result5[0]); end

        $display("Generate assign: pass=%0d fail=%0d", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
