/*
:name: test_parameter_override_edge_cases
:description: Parameter override edge cases
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.2.1 23.10.2.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameter_override_edge_cases.expected
*/
// IEEE 1800-2023 §23.10: Parameter override edge cases
// Tests for parameter value overrides

module param_mod #(
    parameter WIDTH = 8,
    parameter DEPTH = 4,
    parameter logic [7:0] INIT = 8'hFF
)(
    output logic [WIDTH-1:0] data
);
    initial data = INIT;
endmodule

module test_parameter_override_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] d1;
    logic [15:0] d2;
    logic [3:0] d3;
    logic [7:0] d4;

    // Default parameters
    param_mod u1 (.data(d1));

    // Override by name
    param_mod #(.WIDTH(16), .INIT(8'hAA)) u2 (.data(d2));

    // Override by position
    param_mod #(4, 2, 8'h55) u3 (.data(d3));

    // Partial override
    param_mod #(.INIT(8'h12)) u4 (.data(d4));

    initial begin
        #1;

        // Test 1: Default WIDTH
        test_count++;
        if ($bits(d1) == 8) begin
            pass_count++;
            $display("Test 1 PASS: Default WIDTH = 8");
        end else begin
            $display("Test 1 FAIL: WIDTH unexpected = %0d", $bits(d1));
        end

        // Test 2: Default INIT
        test_count++;
        if (d1 == 8'hFF) begin
            pass_count++;
            $display("Test 2 PASS: Default INIT = %h", d1);
        end else begin
            $display("Test 2 FAIL: INIT unexpected = %h", d1);
        end

        // Test 3: Override WIDTH by name
        test_count++;
        if ($bits(d2) == 16) begin
            pass_count++;
            $display("Test 3 PASS: Override WIDTH = 16");
        end else begin
            $display("Test 3 FAIL: WIDTH unexpected = %0d", $bits(d2));
        end

        // Test 4: Override INIT by name
        test_count++;
        if (d2[7:0] == 8'hAA) begin
            pass_count++;
            $display("Test 4 PASS: Override INIT = %h", d2[7:0]);
        end else begin
            $display("Test 4 FAIL: INIT unexpected = %h", d2[7:0]);
        end

        // Test 5: Override by position WIDTH
        test_count++;
        if ($bits(d3) == 4) begin
            pass_count++;
            $display("Test 5 PASS: Pos WIDTH = 4");
        end else begin
            $display("Test 5 FAIL: Pos WIDTH unexpected");
        end

        // Test 6: Override by position INIT
        test_count++;
        if (d3 == 4'h5) begin
            pass_count++;
            $display("Test 6 PASS: Pos INIT = %h", d3);
        end else begin
            $display("Test 6 FAIL: Pos INIT unexpected = %h", d3);
        end

        // Test 7: Partial override keeps defaults
        test_count++;
        if ($bits(d4) == 8) begin
            pass_count++;
            $display("Test 7 PASS: Partial WIDTH = 8");
        end else begin
            $display("Test 7 FAIL: Partial unexpected");
        end

        // Test 8: Partial override value
        test_count++;
        if (d4 == 8'h12) begin
            pass_count++;
            $display("Test 8 PASS: Partial INIT = %h", d4);
        end else begin
            $display("Test 8 FAIL: Partial unexpected = %h", d4);
        end

        $display("=== Parameter Override Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
