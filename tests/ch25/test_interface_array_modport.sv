/*
:name: test_interface_array_modport
:description: Interface array with modport
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 25.5
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_array_modport.expected
*/
// IEEE 1800-2023 §25.5: Interface array with modport
// Test modport connections through interface arrays

interface data_if;
    logic [7:0] data;
    logic valid;
    logic ready;

    modport producer (
        output data,
        output valid,
        input ready
    );

    modport consumer (
        input data,
        input valid,
        output ready
    );
endinterface

// Producer module - writes to interface array element
module data_producer (data_if.producer port, input logic [7:0] value);
    initial begin
        port.data = value;
        port.valid = 1'b1;
    end
endmodule

// Consumer module - reads from interface array element
module data_consumer (data_if.consumer port);
    initial begin
        port.ready = 1'b1;
    end
endmodule

module test_interface_array_modport;
    // Interface array with 4 elements
    data_if dif[4]();

    // Connect producers and consumers to array elements
    data_producer prod0(.port(dif[0].producer), .value(8'hAA));
    data_producer prod1(.port(dif[1].producer), .value(8'hBB));
    data_consumer cons0(.port(dif[0].consumer));
    data_consumer cons1(.port(dif[1].consumer));

    int test_count = 0;
    int pass_count = 0;

    initial begin
        #1;

        // Test 1: Check producer 0 data
        test_count++;
        if (dif[0].data == 8'hAA) begin
            $display("PASS: dif[0].data = 0x%h (from producer)", dif[0].data);
            pass_count++;
        end else begin
            $display("FAIL: dif[0].data = 0x%h (expected 0xAA)", dif[0].data);
        end

        // Test 2: Check producer 1 data
        test_count++;
        if (dif[1].data == 8'hBB) begin
            $display("PASS: dif[1].data = 0x%h (from producer)", dif[1].data);
            pass_count++;
        end else begin
            $display("FAIL: dif[1].data = 0x%h (expected 0xBB)", dif[1].data);
        end

        // Test 3: Check valid signals
        test_count++;
        if (dif[0].valid == 1'b1 && dif[1].valid == 1'b1) begin
            $display("PASS: valid signals set by producers");
            pass_count++;
        end else begin
            $display("FAIL: valid signals not set");
        end

        // Test 4: Check ready signals from consumers
        test_count++;
        if (dif[0].ready == 1'b1 && dif[1].ready == 1'b1) begin
            $display("PASS: ready signals set by consumers");
            pass_count++;
        end else begin
            $display("FAIL: ready signals not set");
        end

        // Summary
        $display("");
        $display("=== Interface Array with Modport Test Summary ===");
        $display("Tests: %0d/%0d passed", pass_count, test_count);

        if (pass_count == test_count)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end
endmodule
