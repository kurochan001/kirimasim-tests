/*
:name: test_port_complex_expr_extended
:description: Port connection expressions
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.7 23.3.2 23.3.3 4.9.6
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_port_complex_expr_extended.expected
*/
// IEEE 1800-2023 §23.3.2: Port connection expressions
module sub_port(input logic [7:0] data_in, output logic [7:0] data_out);
    assign data_out = data_in + 8'd1;
endmodule

module sub_array_port(input logic [7:0] in_val, output logic [7:0] out_val);
    assign out_val = in_val * 2;
endmodule

module sub_partsel(input logic [3:0] in_nibble, output logic [3:0] out_nibble);
    assign out_nibble = ~in_nibble;
endmodule

module test_port_complex_expr_extended;
    logic [7:0] arr [0:3];
    logic [7:0] arr_result [0:3];
    logic [15:0] wide_sig;
    logic [3:0] nibble_result;
    logic [7:0] out1, out2;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Array element port connection .port(arr[i])
    sub_port u_arr0(.data_in(arr[0]), .data_out(out1));

    // Test 2: Array element port connection with different index
    sub_port u_arr2(.data_in(arr[2]), .data_out(out2));

    // Test 3: Part-select port connection .port(sig[7:0])
    sub_partsel u_psel(.in_nibble(wide_sig[3:0]), .out_nibble(nibble_result));

    initial begin
        // Initialize
        arr[0] = 8'h10;
        arr[1] = 8'h20;
        arr[2] = 8'h30;
        arr[3] = 8'h40;
        wide_sig = 16'hABCD;

        #1;

        // Test 1: arr[0] port connection
        if (out1 === 8'h11) begin
            $display("PASS: Test 1 - arr[0] port: 0x10 + 1 = 0x11");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Expected 0x11, got 0x%h", out1);
            fail_count++;
        end

        // Test 2: arr[2] port connection
        if (out2 === 8'h31) begin
            $display("PASS: Test 2 - arr[2] port: 0x30 + 1 = 0x31");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Expected 0x31, got 0x%h", out2);
            fail_count++;
        end

        // Test 3: Part-select port connection
        if (nibble_result === 4'h2) begin
            $display("PASS: Test 3 - Part-select port: ~4'hD = 4'h2");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Expected 4'h2, got 4'h%h", nibble_result);
            fail_count++;
        end

        // Summary
        $display("\n=== Port Complex Expression Test Summary ===");
        $display("PASS: %0d, FAIL: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");
        $finish;
    end
endmodule
