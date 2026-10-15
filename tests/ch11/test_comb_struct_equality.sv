/*
:name: test_comb_struct_equality
:description: Test: Struct and union equality comparison
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.5 7.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_struct_equality.expected
*/
// Test: Struct and union equality comparison
// Equality of packed and unpacked structures (11.4.5)
module test_comb_struct_equality;
    typedef struct packed {
        logic [7:0] addr;
        logic [7:0] data;
    } bus_t;

    typedef struct {
        int x;
        int y;
    } point_t;

    int pass_count = 0;

    initial begin
        // Test 1: Packed struct equality
        begin
            bus_t a, b;
            a.addr = 8'hAA;
            a.data = 8'h55;
            b.addr = 8'hAA;
            b.data = 8'h55;
            if (a == b) begin
                $display("T1: PASS - identical packed structs are equal");
                pass_count++;
            end else begin
                $display("T1: FAIL - identical packed structs not equal");
            end
        end

        // Test 2: Packed struct inequality
        begin
            bus_t a, b;
            a.addr = 8'hAA;
            a.data = 8'h55;
            b.addr = 8'hAA;
            b.data = 8'hFF;
            if (a != b) begin
                $display("T2: PASS - different packed structs are not equal");
                pass_count++;
            end else begin
                $display("T2: FAIL - different packed structs reported as equal");
            end
        end

        // Test 3: Packed struct assignment and comparison
        begin
            bus_t a, b;
            a.addr = 8'h12;
            a.data = 8'h34;
            b = a;
            if (a == b) begin
                $display("T3: PASS - assigned packed struct equals source");
                pass_count++;
            end else begin
                $display("T3: FAIL - assigned packed struct not equal");
            end
        end

        // Test 4: Packed struct with zero values
        begin
            bus_t a, b;
            a = '0;
            b = '0;
            if (a == b) begin
                $display("T4: PASS - zero packed structs are equal");
                pass_count++;
            end else begin
                $display("T4: FAIL - zero packed structs not equal");
            end
        end

        // Test 5: Unpacked struct equality
        begin
            point_t p1, p2;
            p1.x = 10;
            p1.y = 20;
            p2.x = 10;
            p2.y = 20;
            if (p1 == p2) begin
                $display("T5: PASS - identical unpacked structs are equal");
                pass_count++;
            end else begin
                $display("T5: FAIL - identical unpacked structs not equal");
            end
        end

        // Test 6: Unpacked struct inequality
        begin
            point_t p1, p2;
            p1.x = 10;
            p1.y = 20;
            p2.x = 10;
            p2.y = 30;
            if (p1 != p2) begin
                $display("T6: PASS - different unpacked structs are not equal");
                pass_count++;
            end else begin
                $display("T6: FAIL - different unpacked structs reported as equal");
            end
        end

        // Test 7: Packed struct in case statement
        begin
            bus_t pkt;
            pkt.addr = 8'hFF;
            pkt.data = 8'h00;
            case (pkt.addr)
                8'hFF: begin
                    $display("T7: PASS - packed struct member in case works");
                    pass_count++;
                end
                default: begin
                    $display("T7: FAIL - packed struct member case mismatch");
                end
            endcase
        end

        // Test 8: Packed struct as function argument equality
        begin
            bus_t a, b;
            a = {8'hDE, 8'hAD};
            b = {8'hDE, 8'hAD};
            if (a === b) begin
                $display("T8: PASS - packed struct case equality works");
                pass_count++;
            end else begin
                $display("T8: FAIL - packed struct case equality failed");
            end
        end

        $display("pass_count = %0d", pass_count);
        if (pass_count == 8)
            $display("PASS: test_comb_struct_equality");
        else
            $display("FAIL: test_comb_struct_equality (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
