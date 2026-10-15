/*
:name: test_interface_modport
:description: Interface modports test
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.5 25.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_modport.expected
*/
// Interface modports test
module test_interface_modport;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Basic modport usage
    basic_modport_if bmif();
    modport_master master1(.mif(bmif.master));
    modport_slave slave1(.mif(bmif.slave));

    // Test 2: Modport with different signal directions
    dir_modport_if dmif();
    dir_master dm1(.dif(dmif.master));
    dir_slave ds1(.dif(dmif.slave));

    // Test 3: Modport with clocking
    logic clk = 0;
    clk_modport_if cmif(clk);

    // Test 4: Multiple modports in one interface
    multi_modport_if mmif();
    multi_reader reader1(.mif(mmif.reader));
    multi_writer writer1(.mif(mmif.writer));

    // Test 5: Modport with task/function access
    func_modport_if fmif();
    func_user fu1(.fif(fmif.user));

    initial begin
        #1;

        // Test 1: Basic modport - master drives, slave receives
        master1.drive_data(8'hAB);
        #1;
        if (slave1.received_data == 8'hAB) begin
            $display("PASS: Test 1 - Basic modport master/slave");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Basic modport failed (%h)", slave1.received_data);
            fail_count++;
        end

        // Test 2: Directional modport
        dm1.send(16'h1234);
        #1;
        if (ds1.last_received == 16'h1234) begin
            $display("PASS: Test 2 - Directional modport");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Directional modport failed");
            fail_count++;
        end

        // Test 3: Clocking modport
        clk = 1; #1; clk = 0; #1;
        cmif.data = 8'h55;
        clk = 1; #1; clk = 0; #1;
        if (cmif.data == 8'h55) begin
            $display("PASS: Test 3 - Clocking modport");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Clocking modport failed");
            fail_count++;
        end

        // Test 4: Multiple modports
        writer1.write_value(32'hDEADBEEF);
        #1;
        if (reader1.read_value() == 32'hDEADBEEF) begin
            $display("PASS: Test 4 - Multiple modports");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Multiple modports failed");
            fail_count++;
        end

        // Test 5: Function modport
        fu1.call_func();
        if (fmif.func_called == 1) begin
            $display("PASS: Test 5 - Function modport");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Function modport failed");
            fail_count++;
        end

        $display("Test Summary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule

interface basic_modport_if;
    logic [7:0] data;
    logic valid;
    logic ready;

    modport master(output data, output valid, input ready);
    modport slave(input data, input valid, output ready);
endinterface

module modport_master(basic_modport_if.master mif);
    task drive_data(logic [7:0] d);
        mif.data = d;
        mif.valid = 1;
    endtask
endmodule

module modport_slave(basic_modport_if.slave mif);
    logic [7:0] received_data;
    always @(*) begin
        if (mif.valid)
            received_data = mif.data;
    end
endmodule

interface dir_modport_if;
    logic [15:0] addr;
    logic [15:0] data;
    logic wr;

    modport master(output addr, output data, output wr);
    modport slave(input addr, input data, input wr);
endinterface

module dir_master(dir_modport_if.master dif);
    task send(logic [15:0] val);
        dif.data = val;
        dif.wr = 1;
    endtask
endmodule

module dir_slave(dir_modport_if.slave dif);
    logic [15:0] last_received;
    always @(*) begin
        if (dif.wr)
            last_received = dif.data;
    end
endmodule

interface clk_modport_if(input logic clk);
    logic [7:0] data;
    logic valid;

    modport sync(input clk, output data, output valid);
endinterface

interface multi_modport_if;
    logic [31:0] shared_data;
    logic lock;

    modport reader(input shared_data, input lock);
    modport writer(output shared_data, output lock);
endinterface

module multi_reader(multi_modport_if.reader mif);
    function logic [31:0] read_value();
        return mif.shared_data;
    endfunction
endmodule

module multi_writer(multi_modport_if.writer mif);
    task write_value(logic [31:0] val);
        mif.shared_data = val;
    endtask
endmodule

interface func_modport_if;
    int func_called = 0;

    function void mark_called();
        func_called = 1;
    endfunction

    modport user(import mark_called);
endinterface

module func_user(func_modport_if.user fif);
    task call_func();
        fif.mark_called();
    endtask
endmodule
