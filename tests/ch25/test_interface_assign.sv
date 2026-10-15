/*
:name: test_interface_assign
:description: Test: Interface signal assignment
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 25.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_assign.expected
*/
// Test: Interface signal assignment

interface simple_if;
    logic [7:0] data;
    logic valid;
    logic ready;
    logic [3:0] addr;

    modport master (output data, valid, addr, input ready);
    modport slave (input data, valid, addr, output ready);
endinterface

interface bus_if;
    logic clk;
    logic rst_n;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic [15:0] addr;
    logic wen, ren;
    logic ack;
endinterface

module producer(simple_if.master mif);
    initial begin
        mif.data = 8'hAB;
        mif.valid = 1;
        mif.addr = 4'h5;
    end
endmodule

module consumer(simple_if.slave sif);
    initial begin
        #1;
        sif.ready = 1;
    end
endmodule

module test_interface_assign;
    int pass_count = 0;
    int total_tests = 12;

    simple_if sif();
    bus_if bif();

    producer prod(sif);
    consumer cons(sif);

    initial begin
        // Initialize
        sif.data = 0;
        sif.valid = 0;
        sif.ready = 0;
        sif.addr = 0;

        bif.clk = 0;
        bif.rst_n = 0;
        bif.wdata = 0;
        bif.rdata = 0;
        bif.addr = 0;
        bif.wen = 0;
        bif.ren = 0;
        bif.ack = 0;

        #5;

        // Test 1: Direct interface signal assignment
        sif.data = 8'hCD;
        if (sif.data == 8'hCD) begin
            pass_count++;
            $display("PASS: Direct interface signal assign");
        end else $display("FAIL: Direct interface signal assign");

        // Test 2: Interface bit assignment
        sif.valid = 1;
        if (sif.valid == 1) begin
            pass_count++;
            $display("PASS: Interface bit assignment");
        end else $display("FAIL: Interface bit assignment");

        // Test 3: Interface address assignment
        sif.addr = 4'hF;
        if (sif.addr == 4'hF) begin
            pass_count++;
            $display("PASS: Interface address assignment");
        end else $display("FAIL: Interface address assignment");

        // Test 4: Bus interface clock toggle
        bif.clk = 1;
        #1;
        bif.clk = 0;
        #1;
        bif.clk = 1;
        if (bif.clk == 1) begin
            pass_count++;
            $display("PASS: Bus interface clock toggle");
        end else $display("FAIL: Bus interface clock toggle");

        // Test 5: Bus interface reset
        bif.rst_n = 0;
        #1;
        bif.rst_n = 1;
        if (bif.rst_n == 1) begin
            pass_count++;
            $display("PASS: Bus interface reset");
        end else $display("FAIL: Bus interface reset");

        // Test 6: Wide data assignment
        bif.wdata = 32'hDEADBEEF;
        if (bif.wdata == 32'hDEADBEEF) begin
            pass_count++;
            $display("PASS: Wide data assignment");
        end else $display("FAIL: Wide data assignment");

        // Test 7: Read data assignment
        bif.rdata = 32'hCAFEBABE;
        if (bif.rdata == 32'hCAFEBABE) begin
            pass_count++;
            $display("PASS: Read data assignment");
        end else $display("FAIL: Read data assignment");

        // Test 8: Address assignment
        bif.addr = 16'h1234;
        if (bif.addr == 16'h1234) begin
            pass_count++;
            $display("PASS: Address assignment");
        end else $display("FAIL: Address assignment");

        // Test 9: Control signal assignments
        bif.wen = 1;
        bif.ren = 0;
        if (bif.wen == 1 && bif.ren == 0) begin
            pass_count++;
            $display("PASS: Control signal assignments");
        end else $display("FAIL: Control signal assignments");

        // Test 10: Ack signal
        bif.ack = 1;
        if (bif.ack == 1) begin
            pass_count++;
            $display("PASS: Ack signal assignment");
        end else $display("FAIL: Ack signal assignment");

        // Test 11: Interface signal from expression
        sif.data = bif.wdata[7:0];
        if (sif.data == 8'hEF) begin
            pass_count++;
            $display("PASS: Interface from expression");
        end else $display("FAIL: Interface from expression");

        // Test 12: Multiple interface signals in sequence
        sif.data = 8'h11;
        sif.addr = 4'h2;
        sif.valid = 1;
        sif.ready = 1;
        if (sif.data == 8'h11 && sif.addr == 4'h2 && sif.valid && sif.ready) begin
            pass_count++;
            $display("PASS: Multiple interface signals");
        end else $display("FAIL: Multiple interface signals");

        if (pass_count == total_tests) $display("PASS: interface_assign (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: interface_assign (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
