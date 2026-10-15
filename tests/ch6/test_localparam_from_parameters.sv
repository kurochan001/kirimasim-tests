/*
:name: test_localparam_from_parameters
:description: Localparams computed from parameters differ per instance and are read hierarchically
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.4 23.10 23.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_localparam_from_parameters.expected
*/
// IEEE 1800-2023 6.20.4, 23.10: localparams computed from parameters
// Tests localparam values derived from parameters
// Verifies computed local parameters

module compute_module #(
    parameter int BASE = 10,
    parameter int MULT = 2
);
    localparam int COMPUTED = BASE * MULT;
    localparam int HALF = BASE / 2;
    localparam int PLUS_ONE = BASE + 1;

    logic [COMPUTED-1:0] wide_sig;
    logic [HALF-1:0] half_sig;

    // No display here: three instances printing at time 0 would have no defined order (4.7).
endmodule

module test_localparam_from_parameters;
    int pass_count = 0;
    int fail_count = 0;

    // Different parameter sets
    compute_module #(.BASE(10), .MULT(2)) u_default();
    compute_module #(.BASE(8), .MULT(4)) u_custom();
    compute_module #(.BASE(16), .MULT(1)) u_wide();

    initial begin
        $display("=== Localparams computed from parameters ===");

        // Test 1: Default computed value
        if (u_default.COMPUTED == 20) begin
            $display("PASS: Default COMPUTED = 10 * 2 = 20");
            pass_count++;
        end else begin
            $display("FAIL: Default COMPUTED = %0d", u_default.COMPUTED);
            fail_count++;
        end

        // Test 2: Custom computed value
        if (u_custom.COMPUTED == 32) begin
            $display("PASS: Custom COMPUTED = 8 * 4 = 32");
            pass_count++;
        end else begin
            $display("FAIL: Custom COMPUTED = %0d", u_custom.COMPUTED);
            fail_count++;
        end

        // Test 3: Wide computed value
        if (u_wide.COMPUTED == 16) begin
            $display("PASS: Wide COMPUTED = 16 * 1 = 16");
            pass_count++;
        end else begin
            $display("FAIL: Wide COMPUTED = %0d", u_wide.COMPUTED);
            fail_count++;
        end

        // Test 4: HALF localparam
        if (u_default.HALF == 5) begin
            $display("PASS: Default HALF = 10 / 2 = 5");
            pass_count++;
        end else begin
            $display("FAIL: Default HALF = %0d", u_default.HALF);
            fail_count++;
        end

        // Test 5: PLUS_ONE localparam
        if (u_custom.PLUS_ONE == 9) begin
            $display("PASS: Custom PLUS_ONE = 8 + 1 = 9");
            pass_count++;
        end else begin
            $display("FAIL: Custom PLUS_ONE = %0d", u_custom.PLUS_ONE);
            fail_count++;
        end

        // Test 6: Wide HALF
        if (u_wide.HALF == 8) begin
            $display("PASS: Wide HALF = 16 / 2 = 8");
            pass_count++;
        end else begin
            $display("FAIL: Wide HALF = %0d", u_wide.HALF);
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
