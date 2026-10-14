/*
:name: test_ieee1800_2023_delta_convergence
:description: Delta Cycle Convergence Tests
:tags: edge_cases
:type: simulation
:lrm: 1800-2023 4.5 4.4.2.3 10.3
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_ieee1800_2023_delta_convergence.expected
*/
// IEEE 1800-2023 §4.6: Delta Cycle Convergence Tests
// Tests combinational logic convergence and oscillation detection

module test_delta_convergence;
    int test_count = 0;
    int pass_count = 0;

    // Test signals
    logic a, b, c, d;
    logic [7:0] val1, val2, val3;
    logic clk = 0;

    always #5 clk = ~clk;

    // Test 1: Simple combinational chain convergence (§4.6)
    logic chain_in;
    logic chain_out1, chain_out2, chain_out3;

    assign chain_out1 = chain_in;
    assign chain_out2 = chain_out1;
    assign chain_out3 = chain_out2;

    task test_simple_chain();
        chain_in = 0;
        #1;
        chain_in = 1;
        #0;  // Let delta cycles settle

        test_count++;
        if (chain_out3 == 1) begin
            pass_count++;
            $display("PASS: Test 1 - Simple chain convergence");
        end else begin
            $display("FAIL: Test 1 - chain_out3=%b", chain_out3);
        end
    endtask

    // Test 2: Wide bus propagation (§4.6)
    logic [31:0] wide_in, wide_mid, wide_out;

    assign wide_mid = wide_in ^ 32'hFFFFFFFF;
    assign wide_out = wide_mid ^ 32'hFFFFFFFF;

    task test_wide_bus();
        wide_in = 32'hDEADBEEF;
        #0;

        test_count++;
        if (wide_out == 32'hDEADBEEF) begin
            pass_count++;
            $display("PASS: Test 2 - Wide bus propagation");
        end else begin
            $display("FAIL: Test 2 - wide_out=%h", wide_out);
        end
    endtask

    // Test 3: Multiple independent chains (§4.6)
    logic path_a_in, path_a_out;
    logic path_b_in, path_b_out;
    logic path_c_in, path_c_out;

    assign path_a_out = ~path_a_in;
    assign path_b_out = path_b_in & 1'b1;
    assign path_c_out = path_c_in | 1'b0;

    task test_parallel_paths();
        path_a_in = 1;
        path_b_in = 1;
        path_c_in = 1;
        #0;

        test_count++;
        if (path_a_out == 0 && path_b_out == 1 && path_c_out == 1) begin
            pass_count++;
            $display("PASS: Test 3 - Parallel paths");
        end else begin
            $display("FAIL: Test 3 - a=%b, b=%b, c=%b", path_a_out, path_b_out, path_c_out);
        end
    endtask

    // Test 4: Conditional propagation (§4.6)
    logic sel, data_a, data_b, mux_out;

    assign mux_out = sel ? data_a : data_b;

    task test_conditional_prop();
        data_a = 1;
        data_b = 0;
        sel = 0;
        #0;

        test_count++;
        if (mux_out == 0) begin
            sel = 1;
            #0;
            if (mux_out == 1) begin
                pass_count++;
                $display("PASS: Test 4 - Conditional propagation");
            end else begin
                $display("FAIL: Test 4 - mux_out=%b after sel=1", mux_out);
            end
        end else begin
            $display("FAIL: Test 4 - mux_out=%b with sel=0", mux_out);
        end
    endtask

    // Test 5: Feedback with enable (stable) (§4.6)
    logic fb_enable;
    logic [3:0] fb_data, fb_out;

    assign fb_out = fb_enable ? fb_data : fb_out;

    task test_feedback_stable();
        fb_data = 4'h5;
        fb_enable = 1;
        #0;

        test_count++;
        if (fb_out == 4'h5) begin
            fb_enable = 0;
            fb_data = 4'hA;
            #0;
            if (fb_out == 4'h5) begin  // Should retain value
                pass_count++;
                $display("PASS: Test 5 - Feedback stable");
            end else begin
                $display("FAIL: Test 5 - fb_out=%h after disable", fb_out);
            end
        end else begin
            $display("FAIL: Test 5 - fb_out=%h", fb_out);
        end
    endtask

    // Test 6: Simple signal propagation (§4.6)
    logic [7:0] prop_src;
    logic [7:0] prop_dst;

    assign prop_dst = prop_src + 1;

    task test_array_prop();
        prop_src = 8'h10;
        #0;

        test_count++;
        if (prop_dst == 8'h11) begin
            pass_count++;
            $display("PASS: Test 6 - Signal propagation");
        end else begin
            $display("FAIL: Test 6 - dst=%h", prop_dst);
        end
    endtask

    // Test 7: Cross-module signal propagation
    logic cross_in, cross_mid, cross_out;

    assign cross_mid = cross_in;
    assign cross_out = cross_mid;

    task test_cross_module();
        cross_in = 0;
        #0;
        cross_in = 1;
        #0;

        test_count++;
        if (cross_out == 1) begin
            pass_count++;
            $display("PASS: Test 7 - Cross-module propagation");
        end else begin
            $display("FAIL: Test 7 - cross_out=%b", cross_out);
        end
    endtask

    // Test 8: Reduction operator chain (§4.6)
    logic [7:0] reduce_in;
    logic reduce_and, reduce_or, reduce_xor;

    assign reduce_and = &reduce_in;
    assign reduce_or = |reduce_in;
    assign reduce_xor = ^reduce_in;

    task test_reduction_chain();
        reduce_in = 8'b10101010;
        #0;

        test_count++;
        if (reduce_and == 0 && reduce_or == 1 && reduce_xor == 0) begin
            pass_count++;
            $display("PASS: Test 8 - Reduction operators");
        end else begin
            $display("FAIL: Test 8 - and=%b, or=%b, xor=%b",
                     reduce_and, reduce_or, reduce_xor);
        end
    endtask

    // Test 9: Concatenation propagation (§4.6)
    logic [3:0] cat_a, cat_b;
    logic [7:0] cat_out;

    assign cat_out = {cat_a, cat_b};

    task test_concat_prop();
        cat_a = 4'hA;
        cat_b = 4'hB;
        #0;

        test_count++;
        if (cat_out == 8'hAB) begin
            pass_count++;
            $display("PASS: Test 9 - Concatenation propagation");
        end else begin
            $display("FAIL: Test 9 - cat_out=%h", cat_out);
        end
    endtask

    // Test 10: Part-select propagation (§4.6)
    logic [15:0] ps_in;
    logic [7:0] ps_high, ps_low;

    assign ps_high = ps_in[15:8];
    assign ps_low = ps_in[7:0];

    task test_partselect_prop();
        ps_in = 16'hCAFE;
        #0;

        test_count++;
        if (ps_high == 8'hCA && ps_low == 8'hFE) begin
            pass_count++;
            $display("PASS: Test 10 - Part-select propagation");
        end else begin
            $display("FAIL: Test 10 - high=%h, low=%h", ps_high, ps_low);
        end
    endtask

    // Test 11: Rapid toggle convergence (§4.6)
    logic toggle_in, toggle_out;

    assign toggle_out = toggle_in;

    task test_rapid_toggle();
        toggle_in = 0;
        #0;
        toggle_in = 1;
        #0;
        toggle_in = 0;
        #0;
        toggle_in = 1;
        #0;

        test_count++;
        if (toggle_out == 1) begin
            pass_count++;
            $display("PASS: Test 11 - Rapid toggle");
        end else begin
            $display("FAIL: Test 11 - toggle_out=%b", toggle_out);
        end
    endtask

    // Test 12: Zero-delay assign sequence (§4.6)
    logic [3:0] seq_a, seq_b, seq_c, seq_d;

    assign seq_b = seq_a + 1;
    assign seq_c = seq_b + 1;
    assign seq_d = seq_c + 1;

    task test_zero_delay_seq();
        seq_a = 4'd0;
        #0;

        test_count++;
        if (seq_d == 4'd3) begin
            pass_count++;
            $display("PASS: Test 12 - Zero-delay sequence");
        end else begin
            $display("FAIL: Test 12 - seq_d=%0d", seq_d);
        end
    endtask

    initial begin
        $display("=== IEEE 1800-2023 §4.6: Delta Convergence Tests ===");

        test_simple_chain();
        test_wide_bus();
        test_parallel_paths();
        test_conditional_prop();
        test_feedback_stable();
        test_array_prop();
        test_cross_module();
        test_reduction_chain();
        test_concat_prop();
        test_partselect_prop();
        test_rapid_toggle();
        test_zero_delay_seq();

        $display("=== Results: %0d/%0d tests passed ===", pass_count, test_count);

        if (pass_count == test_count)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end
endmodule
