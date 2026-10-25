/*
:name: test_std_mailbox_default_type_parameter
:description: A std::mailbox declared without a type parameter takes the default dynamic_singular_type, so one unbounded mailbox from new() carries messages of int, string, real and byte type and checks the type of each at run time, try_get and try_peek returning a negative value for a variable of another type (IEEE 1800-2023 Section 15.4.9, G.4)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4.9 G.4 15.4.1 15.4.5 15.4.6 15.4.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_std_mailbox_default_type_parameter.expected
*/
// IEEE 1800-2023 G.4: the type parameter T of the std mailbox class defaults
// to dynamic_singular_type, a special type that makes the mailbox check types
// at run time, and new takes a bound that defaults to 0. §15.4.9: such a
// mailbox is typeless: it carries messages of any type and keeps the type of
// each. §15.4.1: a bound of 0 makes the mailbox unbounded. §15.4.6, §15.4.8:
// try_get and try_peek return a negative integer, and leave the message, when
// the type of the variable is not equivalent to the type of the oldest
// message, and a positive integer when they take or copy it.
//
// m_any and m_many are std::mailbox with no parameter, made by new with no
// argument. m_many takes 100 messages with try_put. m_any gets an int, a
// string, a real and a byte message, each from a variable of that type, and
// each is then asked for first with a variable of another type, which fails
// and leaves the message (num stays), and then with its own type. byte is not
// equivalent to int (6.22.2). Only the sign of a try_ result is printed,
// since its value is not fixed. Verilator 5.052 does not accept a mailbox
// without a type parameter and Icarus Verilog 13.0 has no mailbox type, so
// :oracle: names no simulator.

module test_std_mailbox_default_type_parameter;
  std::mailbox m_any, m_many;
  int iv = 5, i;
  string sv = "five", s;
  real rv = 5.5, r;
  byte bv = -8'sd5, b;
  int n, r1, r2;

  initial begin
    m_many = new;
    n = 0;
    for (int k = 0; k < 100; k++)
      if (m_many.try_put(k) > 0) n++;
    $display("new(): %0d of 100 try_put stored, num %0d", n, m_many.num());
    m_any = new;
    m_any.put(iv);
    m_any.put(sv);
    m_any.put(rv);
    m_any.put(bv);
    $display("int string real byte put, num %0d", m_any.num());
    r1 = m_any.try_get(s);
    r2 = m_any.try_peek(r);
    $display("int message: try_get(string)<0 %0d, try_peek(real)<0 %0d, num %0d", r1 < 0,
             r2 < 0, m_any.num());
    r1 = m_any.try_get(i);
    $display("int message: try_get(int)>0 %0d, value %0d, num %0d", r1 > 0, i, m_any.num());
    r1 = m_any.try_get(i);
    r2 = m_any.try_get(s);
    $display("string message: try_get(int)<0 %0d, try_get(string)>0 %0d, value %s", r1 < 0,
             r2 > 0, s);
    r1 = m_any.try_peek(b);
    r2 = m_any.try_get(r);
    $display("real message: try_peek(byte)<0 %0d, try_get(real)>0 %0d, value %0.1f", r1 < 0,
             r2 > 0, r);
    r1 = m_any.try_get(i);
    r2 = m_any.try_get(b);
    $display("byte message: try_get(int)<0 %0d, try_get(byte)>0 %0d, value %0d, num %0d",
             r1 < 0, r2 > 0, b, m_any.num());
  end
endmodule
