/*
:name: test_port_inout
:description: Test: Inout port connections
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.2 23.3.3.3 6.6.1
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_port_inout.expected
*/
// Test: Inout port connections
module bidirectional_buffer (
    input  logic oe,           // Output enable
    input  logic [7:0] din,    // Data in (to drive bus)
    output logic [7:0] dout,   // Data out (read from bus)
    inout  wire [7:0] bus      // Bidirectional bus
);
    assign bus = oe ? din : 8'bz;
    assign dout = bus;
endmodule

module bus_transceiver (
    input  logic dir,          // Direction: 1=A->B, 0=B->A
    input  logic enable,       // Enable transceiver
    inout  wire [3:0] port_a,
    inout  wire [3:0] port_b
);
    assign port_b = (enable && dir)  ? port_a : 4'bz;
    assign port_a = (enable && !dir) ? port_b : 4'bz;
endmodule

module test_port_inout;
    // Bidirectional buffer signals
    logic oe1, oe2;
    logic [7:0] din1, din2;
    logic [7:0] dout1, dout2;
    wire [7:0] shared_bus;

    // Two buffers sharing a bus
    bidirectional_buffer u_buf1 (
        .oe(oe1),
        .din(din1),
        .dout(dout1),
        .bus(shared_bus)
    );

    bidirectional_buffer u_buf2 (
        .oe(oe2),
        .din(din2),
        .dout(dout2),
        .bus(shared_bus)
    );

    // Bus transceiver signals
    logic direction, enable;
    wire [3:0] side_a, side_b;

    // External drivers
    logic [3:0] drive_a, drive_b;
    logic drive_a_en, drive_b_en;

    assign side_a = drive_a_en ? drive_a : 4'bz;
    assign side_b = drive_b_en ? drive_b : 4'bz;

    bus_transceiver u_xcvr (
        .dir(direction),
        .enable(enable),
        .port_a(side_a),
        .port_b(side_b)
    );

    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Initialize
        oe1 = 0; oe2 = 0;
        din1 = 8'h00; din2 = 8'h00;
        drive_a_en = 0; drive_b_en = 0;
        drive_a = 4'h0; drive_b = 4'h0;
        direction = 0; enable = 0;
        #1;

        // Test 1: Buffer 1 drives bus
        oe1 = 1; oe2 = 0;
        din1 = 8'hAB;
        #1;
        if (shared_bus == 8'hAB && dout2 == 8'hAB) begin
            $display("PASS: Test 1 - Buffer 1 drives bus, Buffer 2 reads");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - bus=%h, dout2=%h, expected AB", shared_bus, dout2);
            fail_count++;
        end

        // Test 2: Buffer 2 drives bus
        oe1 = 0; oe2 = 1;
        din2 = 8'hCD;
        #1;
        if (shared_bus == 8'hCD && dout1 == 8'hCD) begin
            $display("PASS: Test 2 - Buffer 2 drives bus, Buffer 1 reads");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - bus=%h, dout1=%h, expected CD", shared_bus, dout1);
            fail_count++;
        end

        // Test 3: Both disabled - high-Z
        oe1 = 0; oe2 = 0;
        #1;
        if (shared_bus === 8'bzzzzzzzz) begin
            $display("PASS: Test 3 - Both disabled, bus is high-Z");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - bus=%h, expected high-Z", shared_bus);
            fail_count++;
        end

        // Test 4: Transceiver A->B direction
        enable = 1;
        direction = 1;  // A -> B
        drive_a_en = 1;
        drive_a = 4'h9;
        drive_b_en = 0;
        #1;
        if (side_b == 4'h9) begin
            $display("PASS: Test 4 - Transceiver A->B direction");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - side_b=%h, expected 9", side_b);
            fail_count++;
        end

        // Test 5: Transceiver B->A direction
        direction = 0;  // B -> A
        drive_a_en = 0;
        drive_b_en = 1;
        drive_b = 4'h6;
        #1;
        if (side_a == 4'h6) begin
            $display("PASS: Test 5 - Transceiver B->A direction");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - side_a=%h, expected 6", side_a);
            fail_count++;
        end

        $display("\n=== Inout Port Test Summary ===");
        $display("PASS: %0d, FAIL: %0d", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
