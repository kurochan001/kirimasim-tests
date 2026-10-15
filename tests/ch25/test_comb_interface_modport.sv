/*
:name: test_comb_interface_modport
:description: Test: Interface modport and virtual interface
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.5 25.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_interface_modport.expected
*/
// Test: Interface modport and virtual interface
// Verifies IEEE 1800-2023 §25.4 modports, §25.9 virtual interfaces
interface simple_bus;
    logic [7:0] data;
    logic       valid;
    logic       ready;

    modport master(output data, output valid, input ready);
    modport slave(input data, input valid, output ready);
endinterface

module producer(simple_bus.master bus);
    initial begin
        bus.data = 8'hAA;
        bus.valid = 1;
    end
endmodule

module consumer(simple_bus.slave bus);
    initial begin
        bus.ready = 1;
    end
endmodule

module test_comb_interface_modport;
    int pass_count = 0;
    simple_bus bus();

    producer p(.bus(bus.master));
    consumer c(.bus(bus.slave));

    initial begin
        #1;
        // T1: producer writes data
        if (bus.data == 8'hAA) begin
            $display("T1: PASS - producer writes data = %h", bus.data);
            pass_count++;
        end else
            $display("T1: FAIL - data = %h", bus.data);

        // T2: producer sets valid
        if (bus.valid == 1) begin
            $display("T2: PASS - valid = 1");
            pass_count++;
        end else
            $display("T2: FAIL - valid = %0b", bus.valid);

        // T3: consumer sets ready
        if (bus.ready == 1) begin
            $display("T3: PASS - ready = 1");
            pass_count++;
        end else
            $display("T3: FAIL - ready = %0b", bus.ready);

        // T4: Virtual interface
        begin
            virtual simple_bus vif;
            vif = bus;
            if (vif.data == 8'hAA && vif.valid == 1 && vif.ready == 1) begin
                $display("T4: PASS - virtual interface reads correctly");
                pass_count++;
            end else
                $display("T4: FAIL");
        end

        // T5: Virtual interface write
        begin
            virtual simple_bus vif;
            vif = bus;
            vif.data = 8'h55;
            #1;
            if (bus.data == 8'h55) begin
                $display("T5: PASS - virtual interface write propagates");
                pass_count++;
            end else
                $display("T5: FAIL - bus.data = %h", bus.data);
        end

        // T6: Virtual interface null check
        begin
            virtual simple_bus vif;
            vif = bus;
            if (vif != null) begin
                $display("T6: PASS - vif is not null after assignment");
                pass_count++;
            end else
                $display("T6: FAIL");
        end

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count == 6)
            $display("PASS: test_comb_interface_modport");
        else
            $display("FAIL: test_comb_interface_modport (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
