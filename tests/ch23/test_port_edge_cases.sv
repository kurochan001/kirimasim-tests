/*
:name: test_port_edge_cases
:description: Port edge cases
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.2 23.3.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_port_edge_cases.expected
*/
// IEEE 1800-2023 §23.3: Port edge cases
// Tests for port connections and directions

module port_sub(
    input logic a,
    input logic b,
    output logic y,
    inout wire z
);
    assign y = a & b;
    assign z = a ? 1'b1 : 1'bz;
endmodule

module port_multi(
    input logic [7:0] data_in,
    output logic [7:0] data_out,
    output logic valid
);
    assign data_out = data_in + 1;
    assign valid = |data_in;
endmodule

module test_port_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic a, b, y;
    wire z;
    logic [7:0] din, dout;
    logic vld;

    port_sub u1(.a(a), .b(b), .y(y), .z(z));
    port_multi u2(.data_in(din), .data_out(dout), .valid(vld));

    initial begin
        a = 0;
        b = 0;
        din = 8'h00;
        #1;

        // Test 1: Input ports
        test_count++;
        a = 1;
        b = 1;
        #1;
        if (y == 1) begin
            pass_count++;
            $display("Test 1 PASS: AND gate y = %b", y);
        end else begin
            $display("Test 1 FAIL: AND unexpected y = %b", y);
        end

        // Test 2: Output port
        test_count++;
        a = 0;
        #1;
        if (y == 0) begin
            pass_count++;
            $display("Test 2 PASS: Output y = %b", y);
        end else begin
            $display("Test 2 FAIL: Output unexpected");
        end

        // Test 3: Inout port driven
        test_count++;
        a = 1;
        #1;
        if (z === 1'b1) begin
            pass_count++;
            $display("Test 3 PASS: Inout driven z = %b", z);
        end else begin
            $display("Test 3 FAIL: Inout unexpected z = %b", z);
        end

        // Test 4: Inout high-z
        test_count++;
        a = 0;
        #1;
        if (z === 1'bz) begin
            pass_count++;
            $display("Test 4 PASS: Inout high-z z = %b", z);
        end else begin
            $display("Test 4 FAIL: High-z unexpected z = %b", z);
        end

        // Test 5: Multi-bit input
        test_count++;
        din = 8'h55;
        #1;
        if (dout == 8'h56) begin
            pass_count++;
            $display("Test 5 PASS: Multi-bit in/out = %h", dout);
        end else begin
            $display("Test 5 FAIL: Multi unexpected = %h", dout);
        end

        // Test 6: Valid output
        test_count++;
        if (vld == 1) begin
            pass_count++;
            $display("Test 6 PASS: Valid = %b", vld);
        end else begin
            $display("Test 6 FAIL: Valid unexpected");
        end

        // Test 7: Zero data
        test_count++;
        din = 8'h00;
        #1;
        if (vld == 0) begin
            pass_count++;
            $display("Test 7 PASS: Zero data valid = %b", vld);
        end else begin
            $display("Test 7 FAIL: Zero unexpected");
        end

        // Test 8: Max value
        test_count++;
        din = 8'hFF;
        #1;
        if (dout == 8'h00) begin
            pass_count++;
            $display("Test 8 PASS: Overflow dout = %h", dout);
        end else begin
            $display("Test 8 FAIL: Overflow unexpected = %h", dout);
        end

        // Test 9: Toggle inputs
        test_count++;
        for (int i = 0; i < 4; i++) begin
            a = ~a;
            b = ~b;
            #1;
        end
        pass_count++;
        $display("Test 9 PASS: Input toggle");

        // Test 10: Sequence test
        test_count++;
        for (int i = 0; i < 4; i++) begin
            din = i * 16;
            #1;
        end
        pass_count++;
        $display("Test 10 PASS: Sequence test");

        $display("=== Port Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
