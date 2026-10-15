/*
:name: test_interface_access_with_modports
:description: Interface with modports, accessed through the interface instance (IEEE 1800-2023 Sections 25.3 and 25.5)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 25.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_access_with_modports.expected
*/
// IEEE 1800-2023 §25.3 and §25.5: an interface with modports, whose variables
// are written and read through the interface instance (not through a modport)

interface data_if;
    logic [7:0] send_data;
    logic [7:0] recv_data;
    logic valid;
    logic ready;

    // Producer modport: writes to send_data and valid
    modport producer (
        output send_data,
        output valid,
        input ready,
        input recv_data
    );

    // Consumer modport: reads from send_data and valid
    modport consumer (
        input send_data,
        input valid,
        output ready,
        output recv_data
    );
endinterface

module test;
    data_if dif();

    int test_count = 0;
    int pass_count = 0;

    initial begin
        // Test direct interface signal access (without modport)
        dif.send_data = 8'hAA;
        dif.recv_data = 8'h55;
        dif.valid = 1'b1;
        dif.ready = 1'b0;

        #1;

        // Test 1: Verify send_data was written
        test_count++;
        if (dif.send_data == 8'hAA) begin
            $display("PASS: send_data = 0x%h", dif.send_data);
            pass_count++;
        end else begin
            $display("FAIL: send_data = 0x%h (expected 0xAA)", dif.send_data);
        end

        // Test 2: Verify recv_data was written
        test_count++;
        if (dif.recv_data == 8'h55) begin
            $display("PASS: recv_data = 0x%h", dif.recv_data);
            pass_count++;
        end else begin
            $display("FAIL: recv_data = 0x%h (expected 0x55)", dif.recv_data);
        end

        // Test 3: Verify valid was written
        test_count++;
        if (dif.valid == 1'b1) begin
            $display("PASS: valid = %b", dif.valid);
            pass_count++;
        end else begin
            $display("FAIL: valid = %b (expected 1)", dif.valid);
        end

        // Test 4: Verify ready was written
        test_count++;
        if (dif.ready == 1'b0) begin
            $display("PASS: ready = %b", dif.ready);
            pass_count++;
        end else begin
            $display("FAIL: ready = %b (expected 0)", dif.ready);
        end

        // Summary
        $display("");
        $display("=== Modport Basic Test Summary ===");
        $display("Tests: %0d/%0d passed", pass_count, test_count);

        if (pass_count == test_count)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end
endmodule
