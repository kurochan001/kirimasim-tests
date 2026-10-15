/*
:name: test_virtual_if_array
:description: Test: Virtual interface array
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9 25.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_if_array.expected
*/
// Test: Virtual interface array
// Tests arrays of virtual interfaces

interface channel_if;
    logic [7:0] data;
    logic valid;
    logic ack;

    modport tx (output data, output valid, input ack);
    modport rx (input data, input valid, output ack);
endinterface

class MultiChannelDriver;
    virtual channel_if vif_array[4];
    int num_channels;

    function new();
        num_channels = 4;
    endfunction

    function void connect(int idx, virtual channel_if vif);
        if (idx >= 0 && idx < num_channels)
            vif_array[idx] = vif;
    endfunction

    task drive_channel(int idx, input [7:0] d);
        if (vif_array[idx] == null) begin
            $display("Warning: Channel %0d not connected", idx);
            return;
        end
        vif_array[idx].data = d;
        vif_array[idx].valid = 1;
        #1;
        wait(vif_array[idx].ack);
        vif_array[idx].valid = 0;
        #1;
    endtask

    task drive_all(input [7:0] d);
        for (int i = 0; i < num_channels; i++) begin
            if (vif_array[i] != null) begin
                vif_array[i].data = d + i;
                vif_array[i].valid = 1;
            end
        end
    endtask

    function int count_connected();
        int cnt = 0;
        for (int i = 0; i < num_channels; i++)
            if (vif_array[i] != null) cnt++;
        return cnt;
    endfunction
endclass

module test_virtual_if_array;
    channel_if ch[4]();

    MultiChannelDriver drv;

    int pass_count = 0;
    int fail_count = 0;

    // Responders for each channel
    initial begin
        forever begin
            @(posedge ch[0].valid);
            #1 ch[0].ack = 1;
            #1 ch[0].ack = 0;
        end
    end

    initial begin
        forever begin
            @(posedge ch[1].valid);
            #1 ch[1].ack = 1;
            #1 ch[1].ack = 0;
        end
    end

    initial begin
        forever begin
            @(posedge ch[2].valid);
            #1 ch[2].ack = 1;
            #1 ch[2].ack = 0;
        end
    end

    initial begin
        forever begin
            @(posedge ch[3].valid);
            #1 ch[3].ack = 1;
            #1 ch[3].ack = 0;
        end
    end

    initial begin
        // Initialize each channel
        ch[0].data = 8'h00;
        ch[0].valid = 0;
        ch[0].ack = 0;
        ch[1].data = 8'h00;
        ch[1].valid = 0;
        ch[1].ack = 0;
        ch[2].data = 8'h00;
        ch[2].valid = 0;
        ch[2].ack = 0;
        ch[3].data = 8'h00;
        ch[3].valid = 0;
        ch[3].ack = 0;
        #1;

        // Test 1: Create driver and connect channels
        drv = new();
        drv.connect(0, ch[0]);
        drv.connect(1, ch[1]);
        drv.connect(2, ch[2]);
        drv.connect(3, ch[3]);

        if (drv.count_connected() == 4) begin
            $display("PASS: Test 1 - All 4 channels connected");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - expected 4 connected, got %0d", drv.count_connected());
            fail_count++;
        end

        // Test 2: Drive single channel
        drv.drive_channel(0, 8'hAA);
        if (ch[0].data == 8'hAA) begin
            $display("PASS: Test 2 - Drive channel 0 works");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - expected 0xAA on ch[0], got 0x%0h", ch[0].data);
            fail_count++;
        end

        // Test 3: Drive different channel
        drv.drive_channel(2, 8'hBB);
        if (ch[2].data == 8'hBB) begin
            $display("PASS: Test 3 - Drive channel 2 works");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - expected 0xBB on ch[2], got 0x%0h", ch[2].data);
            fail_count++;
        end

        // Test 4: Drive all channels simultaneously
        drv.drive_all(8'h10);
        #2;
        if (ch[0].data == 8'h10 && ch[1].data == 8'h11 &&
            ch[2].data == 8'h12 && ch[3].data == 8'h13) begin
            $display("PASS: Test 4 - Drive all channels with offset");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - channel data mismatch");
            fail_count++;
        end

        // Ack all channels
        #1;
        ch[0].ack = 1;
        ch[1].ack = 1;
        ch[2].ack = 1;
        ch[3].ack = 1;
        #1;
        ch[0].ack = 0;
        ch[1].ack = 0;
        ch[2].ack = 0;
        ch[3].ack = 0;
        #1;

        // Test 5: Partial connection
        drv = new();
        drv.connect(0, ch[0]);
        drv.connect(2, ch[2]);
        if (drv.count_connected() == 2) begin
            $display("PASS: Test 5 - Partial connection (2 channels)");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - expected 2 connected, got %0d", drv.count_connected());
            fail_count++;
        end

        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All virtual interface array tests passed");
        else
            $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
