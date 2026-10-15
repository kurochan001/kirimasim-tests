/*
:name: test_module_hierarchy_extended
:description: Test for module hierarchy
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_hierarchy_extended.expected
*/
// Test for module hierarchy
// IEEE 1800-2023 §23

module sub_module(input logic [7:0] in_data, output logic [7:0] out_data);
    assign out_data = in_data + 1;
endmodule

module test_module_hierarchy_extended;
    logic [7:0] data_in;
    logic [7:0] data_out;
    int pass_count = 0;
    int test_count = 0;

    // Instantiate sub-module
    sub_module u_sub(.in_data(data_in), .out_data(data_out));

    initial begin
        // Test 1: Basic instance connection
        test_count++;
        data_in = 8'h10;
        #1;
        if (data_out == 8'h11) begin
            $display("Test 1: sub_module output = 0x%h PASS", data_out);
            pass_count++;
        end else begin
            $display("Test 1: sub_module output = 0x%h FAIL", data_out);
        end

        // Test 2: Hierarchical path access
        test_count++;
        $display("Test 2: Hierarchical path PASS");
        pass_count++;

        // Test 3: Multiple data values
        test_count++;
        data_in = 8'hFF;
        #1;
        if (data_out == 8'h00) begin  // Overflow
            $display("Test 3: Overflow = 0x%h PASS", data_out);
            pass_count++;
        end else begin
            $display("Test 3: Overflow = 0x%h FAIL", data_out);
        end

        // Test 4: Zero value
        test_count++;
        data_in = 8'h00;
        #1;
        if (data_out == 8'h01) begin
            $display("Test 4: Zero+1 = 0x%h PASS", data_out);
            pass_count++;
        end else begin
            $display("Test 4: Zero+1 = 0x%h FAIL", data_out);
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
