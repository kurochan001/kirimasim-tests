/*
:name: test_module_hier
:description: Test for module hierarchy
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_hier.expected
*/
// Test for module hierarchy
// IEEE 1800-2023 §23

module sub_module(
    input logic [7:0] in_val,
    output logic [7:0] out_val
);
    assign out_val = in_val + 1;
endmodule

module test_module_hier;
    logic [7:0] a, b;
    int pass_count = 0;
    int test_count = 0;

    sub_module u_sub(.in_val(a), .out_val(b));

    initial begin
        // Test 1: Basic hierarchy
        test_count++;
        a = 8'h10;
        #1;
        if (b == 8'h11) begin
            $display("Test 1: Basic hierarchy PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL b=%h", b);
        end

        // Test 2: Value propagation
        test_count++;
        a = 8'hFF;
        #1;
        if (b == 8'h00) begin
            $display("Test 2: Overflow PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL b=%h", b);
        end

        // Test 3: Zero input
        test_count++;
        a = 8'h00;
        #1;
        if (b == 8'h01) begin
            $display("Test 3: Zero input PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL b=%h", b);
        end

        // Test 4: Multiple updates
        test_count++;
        for (int i = 0; i < 5; i++) begin
            a = i;
            #1;
        end
        if (b == 8'h05) begin
            $display("Test 4: Multiple updates PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL b=%h", b);
        end

        // Test 5: Large value
        test_count++;
        a = 8'h7F;
        #1;
        if (b == 8'h80) begin
            $display("Test 5: Large value PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL b=%h", b);
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
