/*
:name: test_port_output
:description: Output port connections
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2 23.3.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_port_output.expected
*/
// Output port connections
module status_generator (
    input  logic [7:0] value,
    output logic is_zero,
    output logic is_negative,
    output logic [3:0] upper_nibble,
    output logic [3:0] lower_nibble,
    output logic parity
);
    assign is_zero = (value == 8'd0);
    assign is_negative = value[7];
    assign upper_nibble = value[7:4];
    assign lower_nibble = value[3:0];
    assign parity = ^value;
endmodule

module multi_output (
    input  logic clk,
    input  logic [7:0] data_in,
    output logic [7:0] data_out,
    output logic [7:0] data_inv,
    output logic valid
);
    always_ff @(posedge clk) begin
        data_out <= data_in;
        data_inv <= ~data_in;
        valid <= 1'b1;
    end
endmodule

module test_port_output;
    logic [7:0] test_val;
    logic zero_flag, neg_flag;
    logic [3:0] hi_nibble, lo_nibble;
    logic par_bit;

    // Named output connection
    status_generator u_status (
        .value(test_val),
        .is_zero(zero_flag),
        .is_negative(neg_flag),
        .upper_nibble(hi_nibble),
        .lower_nibble(lo_nibble),
        .parity(par_bit)
    );

    // Some outputs left unconnected
    logic only_zero;
    status_generator u_partial (
        .value(test_val),
        .is_zero(only_zero),
        .is_negative(),      // Unconnected
        .upper_nibble(),     // Unconnected
        .lower_nibble(),     // Unconnected
        .parity()            // Unconnected
    );

    // Clocked output module
    logic clk;
    logic [7:0] in_data, out_data, inv_data;
    logic data_valid;

    multi_output u_multi (
        .clk(clk),
        .data_in(in_data),
        .data_out(out_data),
        .data_inv(inv_data),
        .valid(data_valid)
    );

    int pass_count = 0;
    int fail_count = 0;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Test 1: Zero detection output
        test_val = 8'd0;
        #1;
        if (zero_flag == 1'b1) begin
            $display("PASS: Test 1 - Zero detection output");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - zero_flag = %b, expected 1", zero_flag);
            fail_count++;
        end

        // Test 2: Negative detection output
        test_val = 8'h80;  // -128 in signed
        #1;
        if (neg_flag == 1'b1 && zero_flag == 1'b0) begin
            $display("PASS: Test 2 - Negative detection output");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - neg_flag = %b, expected 1", neg_flag);
            fail_count++;
        end

        // Test 3: Nibble splitting outputs
        test_val = 8'hA5;
        #1;
        if (hi_nibble == 4'hA && lo_nibble == 4'h5) begin
            $display("PASS: Test 3 - Nibble splitting outputs");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - hi=%h, lo=%h, expected A,5", hi_nibble, lo_nibble);
            fail_count++;
        end

        // Test 4: Parity output
        test_val = 8'b10101010;  // Even parity = 0
        #1;
        if (par_bit == 1'b0) begin
            $display("PASS: Test 4 - Parity output (even)");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - par_bit = %b, expected 0", par_bit);
            fail_count++;
        end

        test_val = 8'b10101011;  // Odd parity = 1
        #1;
        if (par_bit == 1'b1) begin
            $display("PASS: Test 4b - Parity output (odd)");
            pass_count++;
        end else begin
            $display("FAIL: Test 4b - par_bit = %b, expected 1", par_bit);
            fail_count++;
        end

        // Test 5: Partial output connection
        test_val = 8'd0;
        #1;
        if (only_zero == 1'b1) begin
            $display("PASS: Test 5 - Partial output connection");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - only_zero incorrect");
            fail_count++;
        end

        // Test 6: Clocked outputs
        in_data = 8'h3C;
        @(posedge clk);
        @(posedge clk);
        if (out_data == 8'h3C && inv_data == 8'hC3 && data_valid == 1'b1) begin
            $display("PASS: Test 6 - Clocked outputs");
            pass_count++;
        end else begin
            $display("FAIL: Test 6 - out=%h, inv=%h, valid=%b", out_data, inv_data, data_valid);
            fail_count++;
        end

        $display("\n=== Output Port Test Summary ===");
        $display("PASS: %0d, FAIL: %0d", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
