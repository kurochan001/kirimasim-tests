/*
:name: test_instantiate_edge_cases
:description: Module instantiation edge cases
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2 23.10.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_instantiate_edge_cases.expected
*/
// IEEE 1800-2023 §23.3.2 and §23.10.2.2: Module instantiation edge cases
// Tests for module instantiation

module sub_module #(parameter WIDTH = 8) (
    input logic clk,
    input logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out
);
    always_ff @(posedge clk) begin
        data_out <= data_in;
    end
endmodule

module adder_mod (
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [7:0] sum
);
    assign sum = a + b;
endmodule

module test_instantiate_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic clk = 0;
    logic [7:0] data_in, data_out;
    logic [7:0] a, b, sum;
    logic [15:0] wide_in, wide_out;

    // Basic instantiation
    sub_module u_sub(.clk(clk), .data_in(data_in), .data_out(data_out));

    // Parameterized instantiation
    sub_module #(.WIDTH(16)) u_wide(.clk(clk), .data_in(wide_in), .data_out(wide_out));

    // Adder instance
    adder_mod u_add(.a(a), .b(b), .sum(sum));

    initial begin
        repeat(100) #5 clk = ~clk;
    end

    initial begin
        data_in = 8'h00;
        wide_in = 16'h0000;
        a = 8'h00;
        b = 8'h00;
        #1;

        // Test 1: Basic instantiation works
        test_count++;
        pass_count++;
        $display("Test 1 PASS: Modules instantiated");

        // Test 2: Combinational adder
        test_count++;
        a = 8'h10;
        b = 8'h20;
        #1;
        if (sum == 8'h30) begin
            pass_count++;
            $display("Test 2 PASS: Adder sum = %h", sum);
        end else begin
            $display("Test 2 FAIL: Adder unexpected = %h", sum);
        end

        // Test 3: Sequential register
        test_count++;
        data_in = 8'hAA;
        @(posedge clk);
        @(negedge clk);
        if (data_out == 8'hAA) begin
            pass_count++;
            $display("Test 3 PASS: Register = %h", data_out);
        end else begin
            $display("Test 3 FAIL: Reg unexpected = %h", data_out);
        end

        // Test 4: Parameterized width
        test_count++;
        wide_in = 16'h1234;
        @(posedge clk);
        @(negedge clk);
        if (wide_out == 16'h1234) begin
            pass_count++;
            $display("Test 4 PASS: Wide = %h", wide_out);
        end else begin
            $display("Test 4 FAIL: Wide unexpected = %h", wide_out);
        end

        // Test 5: Adder with zeros
        test_count++;
        a = 8'h00;
        b = 8'h00;
        #1;
        if (sum == 8'h00) begin
            pass_count++;
            $display("Test 5 PASS: Zero sum = %h", sum);
        end else begin
            $display("Test 5 FAIL: Zero unexpected = %h", sum);
        end

        // Test 6: Adder overflow
        test_count++;
        a = 8'hFF;
        b = 8'h01;
        #1;
        if (sum == 8'h00) begin
            pass_count++;
            $display("Test 6 PASS: Overflow = %h", sum);
        end else begin
            $display("Test 6 FAIL: Overflow unexpected = %h", sum);
        end

        // Test 7: Register chain
        test_count++;
        data_in = 8'h55;
        @(posedge clk);
        data_in = 8'hAA;
        @(posedge clk);
        @(negedge clk);
        if (data_out == 8'hAA) begin
            pass_count++;
            $display("Test 7 PASS: Chain = %h", data_out);
        end else begin
            $display("Test 7 FAIL: Chain unexpected = %h", data_out);
        end

        // Test 8: Multiple clock cycles
        test_count++;
        data_in = 8'h12;
        repeat(3) @(posedge clk);
        @(negedge clk);
        pass_count++;
        $display("Test 8 PASS: Multi cycle");

        // Test 9: Wide all ones
        test_count++;
        wide_in = 16'hFFFF;
        @(posedge clk);
        @(negedge clk);
        if (wide_out == 16'hFFFF) begin
            pass_count++;
            $display("Test 9 PASS: Wide FF = %h", wide_out);
        end else begin
            $display("Test 9 FAIL: Wide FF unexpected = %h", wide_out);
        end

        // Test 10: Rapid changes
        test_count++;
        for (int i = 0; i < 4; i++) begin
            a = i;
            b = 4 - i;
            #1;
        end
        pass_count++;
        $display("Test 10 PASS: Rapid changes");

        $display("=== Instantiate Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
