library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;



entity cpu is
port (
  clk: in std_logic;
  rst: in std_logic;
  input:  in  cpu_input;
  output: out cpu_output
);
end entity cpu;



architecture twoproc of cpu is
  signal di, do: cpu_data;
begin

p_comb: process (input, di)
  variable d: cpu_data;
  variable f: cpu_fetch;
  variable i: cpu_instruction;
  variable r: cpu_registers;
  variable m: cpu_memory;
  variable vd, vs, imm: word;
  variable ip: address;
begin
  d := di;
  f := d.fetch;
  i := d.instruction;
  r := d.registers;
  m := d.memory;
  ip := r(16);

  case d.state is
    when state_fetch0 =>
      f.addr  := 0;
      f.count := 2;
      m.addr  := ip + f.addr;
      d.state := state_fetch1;

    when state_fetch1 =>
      f.data(f.addr) := m.dout;
      f.count := 4 when f.addr = 0 and f.data(0) < 3 else f.count
      f.addr  := f.addr  + 1;
      f.count := f.count - 1;
      if f.count > 0 then
        m.addr  := ip + f.addr;
      else
        d.state := state_decode;
      end if;

    when state_decode =>
      i.op  := cpu_opcode(to_integer(f.data(0)));
      i.rd  := to_integer(f.data(1)(7 downto 4));
      i.rs  := to_integer(f.data(1)(3 downto 0));
      i.imm := to_integer(f.data(3) & f.data(2) when i.op < 3 else unsigned(others => '0'));
      d.state := state_execute;
    
    when state_load0 =>
      r(i.rd)(7 downto 0) := m.dout;
      m.addr  := m.addr + 1;
      d.state := state_load1;
    
    when state_load1 =>
      r(i.rd)(15 downto 8) := m.dout;
      m.addr  := 0;
      d.state := state_fetch0;
    
    when state_store0 =>
      m.addr  := m.addr + 1;
      m.din   := r(i.rd)(15 downto 8);
      m.wr    := '1';
      d.state := state_store1;
    
    when state_store1 =>
      m.addr := 0;
      m.din  := (others => '0');
      m.wr   := '0';
      d.state := state_fetch0;
      
    when execute =>
      vd := d.regs(i.rd)
      vs := d.regs(i.rs)
      imm := i.imm
      case i.op
        when op_ld =>
          m.addr := vs + imm
          d.state := state_load
        when op_st =>
          m.addr := vs + imm;
          m.din  := vd;
          m.wr = '1';
        when op_jmp =>
          ip := vs + imm;
        when op_jz =>
          ip := ip + imm when vs = 0 else ip
        when op_jnz =>
          ip := ip + imm when vs != 0 else ip
        when op_jp =>
          ip := ip + imm when vs > 0 else ip
        when op_jn =>
          ip := ip + imm when vs < 0 else ip
        when op_mov =>
          d.regs(rd) := vs
        when op_and =>
          d.regs(rd) := vd and vs
        when op_or =>
          d.regs(rd) := vd or vs
        when op_not =>
          d.regs(rd) := not vd
        when op_xor =>
          d.regs(rd) := vd xor vs
        when op_add =>
          d.regs(rd) := vd + vs
        when op_adc =>
          d.regs(rd) := vd + vs
        when op_sub =>
          d.regs(rd) := vd - vs
        when op_sbb =>
          d.regs(rd) := vd - vs
        when op_mul =>
          d.regs(rd) := vd and vs
        when op_imul =>
          d.regs(rd) := vd and vs
        when op_div =>
          d.regs(rd) := vd and vs
        when op_idiv =>
          d.regs(rd) := vd and vs
        when others =>
          null; -- bad instruction "halt"
      end case;
  end case;

  r(16) := ip;
  d.memory := m;
  d.registers := r;
  d.instruction := i;
  d.fetch := f;
  do <= d;
end process;

p_seq: process (clk, rst)
  variable o: cpu_output;
begin
  if rst = '1' then
    o.state.run := '0';
    o.state.fetch := '0';
    o.state.decode := '0';
    o.state.execute := '0';
    o.mem.addr := 0;
    o.mem.data := 0;
    o.mem.rd := '0';
    o.mem.wr := '0';
    o.reg.r0 := 0;
    o.reg.r1 := 0;
    o.reg.r2 := 0;
    o.reg.r3 := 0;
    o.reg.ip := 0;
  elsif rising_edge(clk) then
    si <= so;
  end if;
  output <= o;
end process;

end architecture twoproc;
