/*
:name: test_generate_loop_if_case
:description: Generate loop of adders, generate if and generate case selecting continuous assignments
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_loop_if_case.expected
*/
// IEEE 1800-2023 Section 27 - Generate loops, if and case
// Tests: generate for, generate if, generate case
module test_generate_loop_if_case;
    int passed = 0;
    int failed = 0;

    // Generate for - create 4 adders
    logic [7:0] a[4], b[4], sum[4];

    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : gen_adders
            assign sum[i] = a[i] + b[i];
        end
    endgenerate

    // Generate if
    parameter USE_FAST = 1;
    logic [7:0] mult_in, mult_out;

    generate
        if (USE_FAST) begin : gen_fast
            assign mult_out = mult_in << 1; // x2
        end else begin : gen_slow
            assign mult_out = mult_in * 2;
        end
    endgenerate

    // Generate case
    parameter MODE = 1;
    logic [7:0] mode_in, mode_out;

    generate
        case (MODE)
            0: assign mode_out = mode_in;
            1: assign mode_out = mode_in + 1;
            2: assign mode_out = mode_in + 2;
            default: assign mode_out = 8'hFF;
        endcase
    endgenerate

    initial begin
        // Test generated adders
        a[0] = 10; b[0] = 5;
        a[1] = 20; b[1] = 10;
        a[2] = 30; b[2] = 15;
        a[3] = 40; b[3] = 20;
        #1;
        if (sum[0] == 15) passed++; else begin failed++; $display("FAIL: sum[0]"); end
        if (sum[1] == 30) passed++; else begin failed++; $display("FAIL: sum[1]"); end
        if (sum[2] == 45) passed++; else begin failed++; $display("FAIL: sum[2]"); end
        if (sum[3] == 60) passed++; else begin failed++; $display("FAIL: sum[3]"); end

        // Test generate if (fast path)
        mult_in = 25;
        #1;
        if (mult_out == 50) passed++; else begin failed++; $display("FAIL: mult"); end

        // Test generate case (mode 1)
        mode_in = 100;
        #1;
        if (mode_out == 101) passed++; else begin failed++; $display("FAIL: mode"); end

        // Report
        if (failed == 0)
            $display("PASS: All %0d generate tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
