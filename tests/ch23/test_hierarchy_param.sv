/*
:name: test_hierarchy_param
:description: Hierarchical parameter access
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.6 23.10 6.20.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_hierarchy_param.expected
*/
// Hierarchical parameter access
module level3_mod #(
    parameter int L3_WIDTH = 4,
    parameter string L3_NAME = "level3"
);
    localparam int L3_DOUBLE = L3_WIDTH * 2;

    logic [L3_WIDTH-1:0] data;
endmodule

module level2_mod #(
    parameter int L2_DEPTH = 8,
    parameter real L2_GAIN = 1.5
);
    localparam int L2_BITS = $clog2(L2_DEPTH);

    level3_mod #(.L3_WIDTH(L2_BITS + 2)) u_l3();
endmodule

module level1_mod #(
    parameter int L1_SIZE = 16,
    parameter bit L1_ENABLE = 1'b1
);
    localparam int L1_HALF = L1_SIZE / 2;

    level2_mod #(.L2_DEPTH(L1_SIZE)) u_l2_a();
    level2_mod #(.L2_DEPTH(L1_SIZE * 2)) u_l2_b();
endmodule

module test_hierarchy_param;
    // Different parameter configurations
    level1_mod #(.L1_SIZE(32)) u_inst1();
    level1_mod #(.L1_SIZE(64), .L1_ENABLE(1'b0)) u_inst2();

    int pass_count = 0;
    int fail_count = 0;

    initial begin
        #1;

        // Test 1: Top-level parameter access
        if (u_inst1.L1_SIZE == 32) begin
            $display("PASS: Test 1 - Top-level parameter access (L1_SIZE = 32)");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - L1_SIZE = %0d, expected 32", u_inst1.L1_SIZE);
            fail_count++;
        end

        // Test 2: Localparam access
        if (u_inst1.L1_HALF == 16) begin
            $display("PASS: Test 2 - Localparam access (L1_HALF = 16)");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - L1_HALF = %0d, expected 16", u_inst1.L1_HALF);
            fail_count++;
        end

        // Test 3: Nested module parameter (2 levels)
        if (u_inst1.u_l2_a.L2_DEPTH == 32) begin
            $display("PASS: Test 3 - Nested parameter (L2_DEPTH = 32)");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - L2_DEPTH = %0d, expected 32", u_inst1.u_l2_a.L2_DEPTH);
            fail_count++;
        end

        // Test 4: Different instance, different parameter
        if (u_inst1.u_l2_b.L2_DEPTH == 64) begin
            $display("PASS: Test 4 - Second instance parameter (L2_DEPTH = 64)");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - L2_DEPTH = %0d, expected 64", u_inst1.u_l2_b.L2_DEPTH);
            fail_count++;
        end

        // Test 5: Deep nested parameter (3 levels) with derived value
        // L3_WIDTH = L2_BITS + 2 = clog2(32) + 2 = 5 + 2 = 7
        if (u_inst1.u_l2_a.u_l3.L3_WIDTH == 7) begin
            $display("PASS: Test 5 - Deep nested derived parameter");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - L3_WIDTH = %0d, expected 7", u_inst1.u_l2_a.u_l3.L3_WIDTH);
            fail_count++;
        end

        // Test 6: Compare parameters across instances
        if (u_inst1.L1_SIZE != u_inst2.L1_SIZE &&
            u_inst1.L1_SIZE == 32 && u_inst2.L1_SIZE == 64) begin
            $display("PASS: Test 6 - Different instances have different parameters");
            pass_count++;
        end else begin
            $display("FAIL: Test 6 - Instance parameters not independent");
            fail_count++;
        end

        // Test 7: Boolean parameter access
        if (u_inst1.L1_ENABLE == 1'b1 && u_inst2.L1_ENABLE == 1'b0) begin
            $display("PASS: Test 7 - Boolean parameter access");
            pass_count++;
        end else begin
            $display("FAIL: Test 7 - Boolean parameters incorrect");
            fail_count++;
        end

        $display("\n=== Hierarchical Parameter Access Test Summary ===");
        $display("PASS: %0d, FAIL: %0d", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
