/*
:name: test_typedef_struct_enum
:description: Typedef with struct and enum
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.18 6.19 7.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typedef_struct_enum.expected
*/
// IEEE 1800-2023 §6.18: Typedef with struct and enum
// Tests typedef with packed/unpacked structs and enums

module test_typedef_struct_enum;
    int pass_count = 0;
    int test_count = 0;

    // Enum typedef
    typedef enum logic [1:0] {IDLE, RUN, STOP, ERROR} state_e;

    // Packed struct typedef
    typedef struct packed {
        logic [7:0] addr;
        logic [7:0] data;
        logic       valid;
        logic [6:0] reserved;
    } packet_t;

    // Unpacked struct typedef
    typedef struct {
        int x;
        int y;
        string name;
    } point_t;

    // Nested typedef
    typedef struct packed {
        state_e state;
        logic [5:0] counter;
    } status_t;

    initial begin
        // Test 1: Enum typedef basic
        test_count++;
        begin
            state_e s;
            s = IDLE;
            if (s == IDLE) begin
                s = RUN;
                if (s == RUN) begin
                    pass_count++;
                    $display("Test 1 PASS: enum typedef basic");
                end else begin
                    $display("Test 1 FAIL: enum assignment");
                end
            end else begin
                $display("Test 1 FAIL: enum initial value");
            end
        end

        // Test 2: Enum typedef comparison
        test_count++;
        begin
            state_e s1, s2;
            s1 = STOP;
            s2 = STOP;
            if (s1 == s2) begin
                pass_count++;
                $display("Test 2 PASS: enum comparison");
            end else begin
                $display("Test 2 FAIL: enum comparison");
            end
        end

        // Test 3: Packed struct typedef
        test_count++;
        begin
            packet_t p;
            p.addr = 8'hAB;
            p.data = 8'hCD;
            p.valid = 1'b1;
            p.reserved = 7'h0;
            if (p.addr == 8'hAB && p.data == 8'hCD && p.valid) begin
                pass_count++;
                $display("Test 3 PASS: packed struct typedef");
            end else begin
                $display("Test 3 FAIL: packed struct typedef");
            end
        end

        // Test 4: Packed struct bit access
        test_count++;
        begin
            packet_t p;
            p = 24'hABCD80;  // addr=AB, data=CD, valid=1, reserved=0
            if ($bits(p) == 24) begin
                pass_count++;
                $display("Test 4 PASS: packed struct $bits = 24");
            end else begin
                $display("Test 4 FAIL: packed struct $bits (got %0d)", $bits(p));
            end
        end

        // Test 5: Unpacked struct typedef
        test_count++;
        begin
            point_t pt;
            pt.x = 100;
            pt.y = 200;
            pt.name = "origin";
            if (pt.x == 100 && pt.y == 200 && pt.name == "origin") begin
                pass_count++;
                $display("Test 5 PASS: unpacked struct typedef");
            end else begin
                $display("Test 5 FAIL: unpacked struct typedef");
            end
        end

        // Test 6: Nested typedef (struct with enum)
        test_count++;
        begin
            status_t st;
            st.state = RUN;
            st.counter = 6'd42;
            if (st.state == RUN && st.counter == 42) begin
                pass_count++;
                $display("Test 6 PASS: nested typedef (struct with enum)");
            end else begin
                $display("Test 6 FAIL: nested typedef");
            end
        end

        // Test 7: Enum iteration with .first() and .last()
        test_count++;
        begin
            state_e s;
            s = s.first();
            if (s == IDLE) begin
                s = s.last();
                if (s == ERROR) begin
                    pass_count++;
                    $display("Test 7 PASS: enum .first() and .last()");
                end else begin
                    $display("Test 7 FAIL: enum .last()");
                end
            end else begin
                $display("Test 7 FAIL: enum .first()");
            end
        end

        // Test 8: Enum .next() method
        test_count++;
        begin
            state_e s;
            s = IDLE;
            s = s.next();
            if (s == RUN) begin
                s = s.next();
                if (s == STOP) begin
                    pass_count++;
                    $display("Test 8 PASS: enum .next()");
                end else begin
                    $display("Test 8 FAIL: enum .next() second");
                end
            end else begin
                $display("Test 8 FAIL: enum .next() first");
            end
        end

        // Test 9: Enum .prev() method
        test_count++;
        begin
            state_e s;
            s = ERROR;
            s = s.prev();
            if (s == STOP) begin
                pass_count++;
                $display("Test 9 PASS: enum .prev()");
            end else begin
                $display("Test 9 FAIL: enum .prev()");
            end
        end

        // Test 10: Struct array typedef
        test_count++;
        begin
            packet_t packets[2];
            packets[0].addr = 8'h10;
            packets[0].data = 8'h20;
            packets[1].addr = 8'h30;
            packets[1].data = 8'h40;
            if (packets[0].addr == 8'h10 && packets[1].data == 8'h40) begin
                pass_count++;
                $display("Test 10 PASS: struct array typedef");
            end else begin
                $display("Test 10 FAIL: struct array typedef");
            end
        end

        $display("=== Typedef Struct/Enum Test Results ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
