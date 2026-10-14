/*
:name: test_cast_enum
:description: Test: Enum type casting
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19 6.19.5 6.24.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_enum.expected
*/
// Test: Enum type casting

module test_cast_enum;
    int pass_count = 0;
    int total_tests = 0;

    // Enum definitions
    typedef enum {RED, GREEN, BLUE} color_t;
    typedef enum logic [2:0] {IDLE=0, RUN=1, STOP=2, PAUSE=3} state_t;
    typedef enum int {LOW=-10, MID=0, HIGH=10} level_t;
    typedef enum bit [7:0] {CMD_NOP=8'h00, CMD_READ=8'h01, CMD_WRITE=8'h02, CMD_RESET=8'hFF} cmd_t;

    // Test variables
    color_t color;
    state_t state;
    level_t level;
    cmd_t cmd;
    int i;
    logic [31:0] lv;
    bit [7:0] b8;

    initial begin
        // Test 1: enum literal assignment
        total_tests++;
        color = GREEN;
        if (color == GREEN) begin
            pass_count++;
            $display("PASS: enum literal assignment");
        end else $display("FAIL: enum literal");

        // Test 2: enum to int
        total_tests++;
        color = BLUE;
        i = int'(color);
        if (i == 2) begin
            pass_count++;
            $display("PASS: enum to int");
        end else $display("FAIL: enum to int, got %0d", i);

        // Test 3: int to enum (valid value)
        total_tests++;
        i = 1;
        color = color_t'(i);
        if (color == GREEN) begin
            pass_count++;
            $display("PASS: int to enum (valid)");
        end else $display("FAIL: int to enum");

        // Test 4: enum with explicit values
        total_tests++;
        state = PAUSE;
        i = int'(state);
        if (i == 3) begin
            pass_count++;
            $display("PASS: enum with explicit value");
        end else $display("FAIL: explicit enum, got %0d", i);

        // Test 5: enum with negative values
        total_tests++;
        level = LOW;
        i = int'(level);
        if (i == -10) begin
            pass_count++;
            $display("PASS: enum negative value");
        end else $display("FAIL: negative enum, got %0d", i);

        // Test 6: enum to logic vector
        total_tests++;
        cmd = CMD_RESET;
        b8 = cmd;
        if (b8 == 8'hFF) begin
            pass_count++;
            $display("PASS: enum to bit vector");
        end else $display("FAIL: enum to bit, got %h", b8);

        // Test 7: logic vector to enum
        total_tests++;
        b8 = 8'h02;
        cmd = cmd_t'(b8);
        if (cmd == CMD_WRITE) begin
            pass_count++;
            $display("PASS: bit to enum");
        end else $display("FAIL: bit to enum");

        // Test 8: enum comparison
        total_tests++;
        state = RUN;
        if (state > IDLE && state < STOP) begin
            pass_count++;
            $display("PASS: enum comparison");
        end else $display("FAIL: enum comparison");

        // Test 9: enum in case statement
        total_tests++;
        color = RED;
        case (color)
            RED:   i = 100;
            GREEN: i = 200;
            BLUE:  i = 300;
            default: i = 0;
        endcase
        if (i == 100) begin
            pass_count++;
            $display("PASS: enum in case");
        end else $display("FAIL: enum in case, got %0d", i);

        // Test 10: enum.first()
        total_tests++;
        color = color.first();
        if (color == RED) begin
            pass_count++;
            $display("PASS: enum.first()");
        end else $display("FAIL: enum.first()");

        // Test 11: enum.last()
        total_tests++;
        color = color.last();
        if (color == BLUE) begin
            pass_count++;
            $display("PASS: enum.last()");
        end else $display("FAIL: enum.last()");

        // Test 12: enum.next()
        total_tests++;
        color = RED;
        color = color.next();
        if (color == GREEN) begin
            pass_count++;
            $display("PASS: enum.next()");
        end else $display("FAIL: enum.next()");

        // Test 13: enum.prev()
        total_tests++;
        color = BLUE;
        color = color.prev();
        if (color == GREEN) begin
            pass_count++;
            $display("PASS: enum.prev()");
        end else $display("FAIL: enum.prev()");

        // Test 14: enum.num()
        total_tests++;
        i = color.num();
        if (i == 3) begin
            pass_count++;
            $display("PASS: enum.num()");
        end else $display("FAIL: enum.num(), got %0d", i);

        $display("PASS: cast_enum (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
