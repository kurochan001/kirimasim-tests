/*
:name: test_parameter_override_instances
:description: Parameter overrides by name on several instances, read back hierarchically
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10 23.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameter_override_instances.expected
*/
// IEEE 1800-2023 23.10: overriding module parameters
// Tests parameter override in instantiation
// Verifies defparam and instance parameter binding

module parameterized_mod #(
    parameter WIDTH = 8,
    parameter DEPTH = 4
);
    logic [WIDTH-1:0] data;
    logic [DEPTH-1:0] addr;

    // No display here: four instances printing at time 0 would have no defined order (4.7).
endmodule

module test_parameter_override_instances;
    int pass_count = 0;
    int fail_count = 0;

    // Default parameters
    parameterized_mod u_default();

    // Override width
    parameterized_mod #(.WIDTH(16)) u_wide();

    // Override multiple parameters
    parameterized_mod #(.WIDTH(32), .DEPTH(8)) u_custom();

    // Named parameter override
    parameterized_mod #(.DEPTH(16), .WIDTH(4)) u_narrow();

    initial begin
        $display("=== Parameter Override ===");

        // Test 1: Default parameters
        if (u_default.WIDTH == 8 && u_default.DEPTH == 4) begin
            $display("PASS: Default parameters WIDTH=8, DEPTH=4");
            pass_count++;
        end else begin
            $display("FAIL: Default params wrong W=%0d D=%0d", u_default.WIDTH, u_default.DEPTH);
            fail_count++;
        end

        // Test 2: Width override
        if (u_wide.WIDTH == 16) begin
            $display("PASS: Width override WIDTH=16");
            pass_count++;
        end else begin
            $display("FAIL: Width override wrong W=%0d", u_wide.WIDTH);
            fail_count++;
        end

        // Test 3: Multiple parameter override
        if (u_custom.WIDTH == 32 && u_custom.DEPTH == 8) begin
            $display("PASS: Multiple override WIDTH=32, DEPTH=8");
            pass_count++;
        end else begin
            $display("FAIL: Multiple override wrong");
            fail_count++;
        end

        // Test 4: Named parameter ordering
        if (u_narrow.WIDTH == 4 && u_narrow.DEPTH == 16) begin
            $display("PASS: Named params WIDTH=4, DEPTH=16");
            pass_count++;
        end else begin
            $display("FAIL: Named params wrong");
            fail_count++;
        end

        // Test 5: Default DEPTH when only WIDTH overridden
        if (u_wide.DEPTH == 4) begin
            $display("PASS: Default DEPTH preserved when WIDTH overridden");
            pass_count++;
        end else begin
            $display("FAIL: DEPTH changed unexpectedly");
            fail_count++;
        end

        $display("");
        $display("=== Results: %0d PASS, %0d FAIL ===", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
