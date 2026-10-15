/*
:name: test_comb_vif_array
:description: Test: Virtual interface array and parameterized interface
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_vif_array.expected
*/
// Test: Virtual interface array and parameterized interface
// Verifies IEEE 1800-2023 §25.9 virtual interfaces
interface data_if #(parameter WIDTH = 8);
    logic [WIDTH-1:0] data;
    logic valid;

    modport master(output data, output valid);
    modport slave(input data, input valid);
endinterface

module test_comb_vif_array;
    int pass_count = 0;

    data_if #(8) bus0();
    data_if #(8) bus1();
    data_if #(8) bus2();

    initial begin
        // T1: Basic virtual interface
        begin
            virtual data_if #(8) vif;
            vif = bus0;
            vif.data = 8'hAA;
            vif.valid = 1;
            #1;
            if (bus0.data == 8'hAA && bus0.valid == 1) begin
                $display("T1: PASS - vif write: data=%h valid=%b", bus0.data, bus0.valid);
                pass_count++;
            end else
                $display("T1: FAIL");
        end

        // T2: Switch virtual interface target
        begin
            virtual data_if #(8) vif;
            vif = bus1;
            vif.data = 8'h11;
            #1;
            vif = bus2;
            vif.data = 8'h22;
            #1;
            if (bus1.data == 8'h11 && bus2.data == 8'h22) begin
                $display("T2: PASS - switched vif: bus1=%h bus2=%h", bus1.data, bus2.data);
                pass_count++;
            end else
                $display("T2: FAIL - bus1=%h bus2=%h", bus1.data, bus2.data);
        end

        // T3: Read through virtual interface
        begin
            virtual data_if #(8) vif;
            bus0.data = 8'hBB;
            vif = bus0;
            if (vif.data == 8'hBB) begin
                $display("T3: PASS - vif read: %h", vif.data);
                pass_count++;
            end else
                $display("T3: FAIL - vif.data=%h", vif.data);
        end

        // T4: Virtual interface null check
        begin
            virtual data_if #(8) vif;
            if (vif == null) begin
                $display("T4: PASS - unassigned vif is null");
                pass_count++;
            end else
                $display("T4: FAIL");
        end

        // T5: Virtual interface reassignment
        begin
            virtual data_if #(8) vif;
            vif = bus0;
            bus0.data = 8'hCC;
            vif = bus1;
            bus1.data = 8'hDD;
            if (vif.data == 8'hDD) begin
                $display("T5: PASS - reassigned vif reads bus1: %h", vif.data);
                pass_count++;
            end else
                $display("T5: FAIL - vif.data=%h", vif.data);
        end

        // T6: Multiple virtual interfaces to same bus
        begin
            virtual data_if #(8) vif1, vif2;
            vif1 = bus0;
            vif2 = bus0;
            vif1.data = 8'hEE;
            #1;
            if (vif2.data == 8'hEE) begin
                $display("T6: PASS - two vifs to same bus: %h", vif2.data);
                pass_count++;
            end else
                $display("T6: FAIL - vif2.data=%h", vif2.data);
        end

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count == 6)
            $display("PASS: test_comb_vif_array");
        else
            $display("FAIL: test_comb_vif_array (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
