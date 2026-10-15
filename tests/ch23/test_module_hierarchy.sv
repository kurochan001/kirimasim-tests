/*
:name: test_module_hierarchy
:description: Test for module hierarchy functions
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2 23.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_hierarchy.expected
*/
// Test for module hierarchy functions
// IEEE 1800-2023 Section 23

module child_module(input logic [7:0] data_in, output logic [7:0] data_out);
    assign data_out = data_in + 1;
endmodule

module parent_module;
    logic [7:0] in1, out1;
    logic [7:0] in2, out2;
    
    child_module child1(.data_in(in1), .data_out(out1));
    child_module child2(.data_in(in2), .data_out(out2));
endmodule

module test_module_hierarchy;
    int pass_count = 0;
    int test_count = 0;
    
    logic [7:0] a, b, c;
    
    child_module inst1(.data_in(a), .data_out(b));
    child_module inst2(.data_in(b), .data_out(c));

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

        // Test 2: Chained modules
        test_count++;
        a = 8'h20;
        #1;
        if (c == 8'h22) begin
            $display("Test 2: Chained modules PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL c=%h", c);
        end

        // Test 3: Value propagation
        test_count++;
        for (int i = 0; i < 5; i++) begin
            a = i;
            #1;
        end
        if (c == 6) begin
            $display("Test 3: Value propagation PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL c=%0d", c);
        end

        // Test 4: Zero input
        test_count++;
        a = 8'h00;
        #1;
        if (b == 8'h01) begin
            $display("Test 4: Zero input PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Max value
        test_count++;
        a = 8'hFE;
        #1;
        if (b == 8'hFF) begin
            $display("Test 5: Max value PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
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
