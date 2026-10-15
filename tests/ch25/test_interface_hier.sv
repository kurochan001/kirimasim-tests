/*
:name: test_interface_hier
:description: Test interface hierarchy access
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 25.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_hier.expected
*/
// Test interface hierarchy access
interface simple_if;
    logic [7:0] data;
    logic valid;
    logic ready;

    modport master(output data, output valid, input ready);
    modport slave(input data, input valid, output ready);
endinterface

interface complex_if;
    logic [31:0] addr;
    logic [63:0] wdata;
    logic [63:0] rdata;
    logic we;
    logic re;

    modport initiator(output addr, output wdata, input rdata, output we, output re);
    modport target(input addr, input wdata, output rdata, input we, input re);
endinterface

module sub_with_if(simple_if.slave sif);
    always @(*) begin
        sif.ready = sif.valid;
    end
endmodule

module test_interface_hier;
    int pass_count = 0;
    int total_tests = 8;

    simple_if sif1();
    simple_if sif2();
    complex_if cif();

    sub_with_if sub1(.sif(sif1));

    initial begin
        // Initialize interfaces
        sif1.data = 8'h00;
        sif1.valid = 1'b0;
        sif2.data = 8'hFF;
        sif2.valid = 1'b1;
        cif.addr = 32'h0;
        cif.wdata = 64'h0;
        cif.we = 1'b0;
        cif.re = 1'b0;

        #1;

        // Test 1: Access interface signal directly
        sif1.data = 8'hAB;
        #1;
        if (sif1.data == 8'hAB) begin
            $display("Test 1 PASS: sif1.data = %h", sif1.data);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: sif1.data = %h, expected AB", sif1.data);
        end

        // Test 2: Interface valid signal
        sif1.valid = 1'b1;
        #1;
        if (sif1.valid == 1'b1) begin
            $display("Test 2 PASS: sif1.valid = %b", sif1.valid);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: sif1.valid = %b, expected 1", sif1.valid);
        end

        // Test 3: Check ready driven by sub-module
        #1;
        if (sif1.ready == 1'b1) begin
            $display("Test 3 PASS: sif1.ready driven by sub-module = %b", sif1.ready);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: sif1.ready = %b, expected 1", sif1.ready);
        end

        // Test 4: Second interface access
        if (sif2.data == 8'hFF && sif2.valid == 1'b1) begin
            $display("Test 4 PASS: sif2.data = %h, sif2.valid = %b", sif2.data, sif2.valid);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: sif2 values incorrect");
        end

        // Test 5: Complex interface address
        cif.addr = 32'hDEADBEEF;
        #1;
        if (cif.addr == 32'hDEADBEEF) begin
            $display("Test 5 PASS: cif.addr = %h", cif.addr);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: cif.addr = %h, expected DEADBEEF", cif.addr);
        end

        // Test 6: Complex interface 64-bit data
        cif.wdata = 64'hCAFEBABE_12345678;
        #1;
        if (cif.wdata == 64'hCAFEBABE_12345678) begin
            $display("Test 6 PASS: cif.wdata = %h", cif.wdata);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: cif.wdata = %h, expected CAFEBABE12345678", cif.wdata);
        end

        // Test 7: Multiple interface signals
        cif.we = 1'b1;
        cif.re = 1'b0;
        #1;
        if (cif.we == 1'b1 && cif.re == 1'b0) begin
            $display("Test 7 PASS: cif.we = %b, cif.re = %b", cif.we, cif.re);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: Control signals incorrect");
        end

        // Test 8: Read-modify-write on interface
        cif.addr = cif.addr + 32'h100;
        #1;
        if (cif.addr == 32'hDEADBFEF) begin
            $display("Test 8 PASS: cif.addr after increment = %h", cif.addr);
            pass_count++;
        end else begin
            $display("Test 8 FAIL: cif.addr = %h, expected DEADBFEF", cif.addr);
        end

        if (pass_count == total_tests) $display("PASS: interface_hier (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: interface_hier (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
