/*
:name: test_module_generate
:description: Generated module instances test
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5 23.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_generate.expected
*/
// Generated module instances test
module test_module_generate;
    int pass_count = 0;
    int fail_count = 0;

    // Signals
    logic clk = 0;
    logic [7:0] data_in [8];
    logic [7:0] data_out [8];

    // Test 1: Generate for loop
    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : gen_loop
            gen_unit #(.val(i)) gu();
        end
    endgenerate

    // Test 2: Generate if
    parameter USE_FAST = 1;
    generate
        if (USE_FAST) begin : fast_path
            fast_module fm();
        end else begin : slow_path
            slow_module sm();
        end
    endgenerate

    // Test 3: Generate case
    parameter MODE = 2;
    generate
        case (MODE)
            0: begin : mode0
                mode_a_module ma();
            end
            1: begin : mode1
                mode_b_module mb();
            end
            2: begin : mode2
                mode_c_module mc();
            end
            default: begin : mode_default
                mode_default_module md();
            end
        endcase
    endgenerate

    // Test 4: Nested generate
    generate
        for (i = 0; i < 2; i++) begin : outer
            for (genvar j = 0; j < 2; j++) begin : inner
                nested_cell #(.x(i), .y(j)) nc();
            end
        end
    endgenerate

    // Test 5: Generate with parameter override
    generate
        for (i = 0; i < 4; i++) begin : param_gen
            param_gen_mod #(.INDEX(i)) pgm();
        end
    endgenerate

    initial begin
        #1;

        // Test 1: Generate for loop
        if (gen_loop[0].gu.val == 0 && gen_loop[1].gu.val == 1 &&
            gen_loop[2].gu.val == 2 && gen_loop[3].gu.val == 3) begin
            $display("PASS: Test 1 - Generate for loop correct");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Generate for loop incorrect");
            fail_count++;
        end

        // Test 2: Generate if (USE_FAST=1, so fast_path should exist)
        if (fast_path.fm.speed == 100) begin
            $display("PASS: Test 2 - Generate if correct (fast path)");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Generate if incorrect");
            fail_count++;
        end

        // Test 3: Generate case (MODE=2, so mode2 should exist)
        if (mode2.mc.mode_id == 2) begin
            $display("PASS: Test 3 - Generate case correct (mode 2)");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Generate case incorrect");
            fail_count++;
        end

        // Test 4: Nested generate
        if (outer[0].inner[0].nc.x == 0 && outer[0].inner[0].nc.y == 0 &&
            outer[1].inner[1].nc.x == 1 && outer[1].inner[1].nc.y == 1) begin
            $display("PASS: Test 4 - Nested generate correct");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Nested generate incorrect");
            fail_count++;
        end

        // Test 5: Generate with parameter override
        if (param_gen[0].pgm.INDEX == 0 && param_gen[1].pgm.INDEX == 1 &&
            param_gen[2].pgm.INDEX == 2 && param_gen[3].pgm.INDEX == 3) begin
            $display("PASS: Test 5 - Generate with parameters correct");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Generate with parameters incorrect");
            fail_count++;
        end

        $display("Test Summary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule

module gen_unit #(parameter int val = 0)();
endmodule

module fast_module;
    int speed = 100;
endmodule

module slow_module;
    int speed = 10;
endmodule

module mode_a_module;
    int mode_id = 0;
endmodule

module mode_b_module;
    int mode_id = 1;
endmodule

module mode_c_module;
    int mode_id = 2;
endmodule

module mode_default_module;
    int mode_id = -1;
endmodule

module nested_cell #(parameter int x = 0, parameter int y = 0)();
endmodule

module param_gen_mod #(parameter int INDEX = 0)();
endmodule
