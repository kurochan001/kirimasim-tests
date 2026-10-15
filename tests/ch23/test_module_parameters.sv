/*
:name: test_module_parameters
:description: Chapter 23: Modules and hierarchy
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.2.2 23.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_parameters.expected
*/
// IEEE 1800-2023 Chapter 23: Modules and hierarchy
// §23.10.2.2 Parameter value assignment by name, §23.6 hierarchical names

module test_module_parameters;
    // Test parameter passing and overrides

    int test_count;
    int pass_count;

    // Default parameter values
    param_mod #() u_default();

    // Override parameters
    param_mod #(.WIDTH(16), .DEPTH(4)) u_override();

    // Partial override
    param_mod #(.WIDTH(32)) u_partial();

    initial begin
        test_count = 0;
        pass_count = 0;

        #1;

        // Test 1: Default parameters
        test_count++;
        if (u_default.WIDTH == 8 && u_default.DEPTH == 2) pass_count++;
        else $display("FAIL: Default params - WIDTH=%0d, DEPTH=%0d (expected 8, 2)",
                      u_default.WIDTH, u_default.DEPTH);

        // Test 2: Both parameters overridden
        test_count++;
        if (u_override.WIDTH == 16 && u_override.DEPTH == 4) pass_count++;
        else $display("FAIL: Override params - WIDTH=%0d, DEPTH=%0d (expected 16, 4)",
                      u_override.WIDTH, u_override.DEPTH);

        // Test 3: Partial override
        test_count++;
        if (u_partial.WIDTH == 32 && u_partial.DEPTH == 2) pass_count++;
        else $display("FAIL: Partial override - WIDTH=%0d, DEPTH=%0d (expected 32, 2)",
                      u_partial.WIDTH, u_partial.DEPTH);

        // Test 4: Local parameter (cannot be overridden)
        test_count++;
        if (u_default.LOCAL_CONST == 100) pass_count++;
        else $display("FAIL: Localparam - LOCAL_CONST=%0d (expected 100)", u_default.LOCAL_CONST);

        $display("Chapter 23.4 Parameters: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule

module param_mod #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 2
);
    localparam int LOCAL_CONST = 100;

    logic [WIDTH-1:0] data;
    logic [DEPTH-1:0] addr;
endmodule
