library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_cpu.all;



entity top is
port (
  clk:    in  std_logic;
  rst:    in  std_logic;
  run:    in  std_logic;
  mout:   in  mem_output;
  minp:   out mem_input;
  status: out cpu_status
);
end entity top;



architecture bh of top is
  signal xs: cpu_status;
  signal xi: cpu_internal;
begin

p_seq: process (clk, rst)
  variable s: cpu_status;
  variable i: cpu_internal;
  variable m: mem_output;
  variable vd, vs, imm: bits64;
  variable vt: bits65;
  variable zf, cf, sf: std_logic;
begin
  s := xs;
  i := xi;
  m := mout;

  -- reset? clean up
  if rst = '1' then
    s.state := st_halted;
    s.regs  := (others => '0');
    s.flags := (others => '0');
    s.ip    := (others => '0');
    i.op    := (others => '0');
    i.rd    := (others => '0');
    i.rs    := (others => '0');
    i.imm   := (others => '0');
    i.addr  := (others => '0');
    i.data  := (others => '0');
    i.buff  := (others => '0');
    i.wr    := '0';
  
  -- run? do something
  elsif run = '1' then
    case s.state is
      -- was halted? start fetch
      when st_halted =>
        s.state := st_fetch0;
      
      -- request bytes 0-1
      when st_fetch0 =>
        i.addr  := s.ip(15 downto 0);
        s.state := st_fetch1;
      
      -- got bytes 0-1
      -- if short opcode, execute
      -- else request bytes 2-3
      when st_fetch1 =>
        i.op := m.data(7  downto 0);
        i.rd := m.data(11 downto 8);
        i.rs := m.data(15 downto 12);
        i.addr := i.addr + 2;
        case i.op is
          when op_load |
               op_store |
               op_movi |
               op_jmp |
               op_jz |
               op_jnz |
               op_jb |
               op_jbe |
               op_jg |
               op_jge =>
            s.ip    := s.ip + 10;
            s.state := st_fetch2;
          when others =>
            s.ip    := s.ip + 2;
            s.state := st_execute;
        end case;
      
      -- got bytes 2-3
      -- request bytes 4-5
      when st_fetch2 =>
        i.imm(15 downto 0) := m.data;
        i.addr  := i.addr + 2;
        s.state := st_fetch3;
      
      -- got bytes 4-5
      -- request bytes 6-7
      when st_fetch3 =>
        i.imm(31 downto 16) := m.data;
        i.addr  := i.addr + 2;
        s.state := st_fetch4;
      
      -- got bytes 6-7
      -- request bytes 8-9
      when st_fetch4 =>
        i.imm(47 downto 32) := m.data;
        i.addr  := i.addr + 2;
        s.state := st_fetch5;
      
      -- got bytes 8-9
      -- start execution
      when st_fetch5 =>
        d.imm(63 downto 48) := m.data;    
        i.addr  := i.addr + 2;
        s.state := st_execute;
      
      -- got bytes 0-1
      -- request bytes 2-3
      when st_load0 =>
        i.buff(15 downto 0) := m.data;
        i.addr  := i.addr + 2;
        s.state := st_load1;
      
      -- got bytes 2-3
      -- request bytes 4-5
      when st_load1 =>
        i.buff(31 downto 16) := m.data;
        i.addr  := i.addr + 2;
        s.state := st_load1;
      
      -- got bytes 4-5
      -- request bytes 6-7
      when st_load2 =>
        i.buff(47 downto 32) := m.data;
        i.addr  := i.addr + 2;
        s.state := st_load3;
      
      -- got bytes 6-7
      -- set dest register
      -- fetch next instruction
      when st_load3 =>
        i.buff(63 downto 48) := m.data;
        s.regs(i.rd) := i.buff;
        i.addr  := i.addr + 2;
        s.state := st_fetch0;
      
      -- wrote bytes 0-1
      -- send bytes 2-3
      when st_store0 =>
        i.data  := i.buff(31 downto 16);
        i.addr  := i.addr + 2;
        s.state := st_store1;
      
      -- wrote bytes 2-3
      -- send bytes 4-5
      when st_store1 =>
        i.data  := i.buff(47 downto 32);
        i.addr  := i.addr + 2;
        s.state := st_store2;
      
      -- wrote bytes 4-5
      -- send bytes 6-7
      when st_store2 =>
        i.data  := i.buff(63 downto 48);
        i.addr  := i.addr + 2;
        s.state := st_store3;
      
      -- wrote bytes 6-7
      -- stop writing
      -- fetch next instruction
      when st_store3 =>
        i.wr    := '0';
        s.state := st_fetch0;
      
      -- execute instruction
      when st_execute =>
        vd  := s.regs(i.rd)
        vs  := s.regs(i.rs)
        imm := i.imm;
        zf := s.flags(fl_zero)
        sf := s.flags(fl_sign)
        cf := s.flags(fl_carry)
        
        case i.op is
          -- load rd, [rs+imm]
          when op_load =>
            i.addr  := (vs + imm)(15 downto 0);
            s.state := st_load0;
          
          -- store [rd+imm], rs
          when op_store =>
            i.addr := (vd + imm)(15 downto 0);
            i.buff := vs;
            i.data := i.buff(15 downto 0);
            i.wr   := '1';
          
          -- movi rd, imm
          when op_movi =>
            vd := imm;
          
          -- mov rd, rs
          when op_mov =>
            vd := vs;
          
          -- cmp rd, rs
          when op_cmp =>
            vt := vd - vs;
            zf := '1' when vt = 0 else '0';
            sf := '1' when vt < 0 else '0';
            cf := vt(64);
          
          -- jmp imm
          when op_jmp =>
            s.ip := imm;
          
          -- jz imm
          when op_jz =>
            s.ip := imm when zf = '1' else s.ip;
          
          -- jnz imm
          when op_jnz =>
            s.ip := imm when zf = '0' else s.ip;
          
          -- jb imm
          when op_jb =>
            s.ip := imm when sf = '1' and zf = '0' else s.ip;
          
          -- jbe imm
          when op_jbe =>
            s.ip := imm when sf = '1' or zf = '1' else s.ip;
          
          -- jg imm
          when op_jg =>
            s.ip := imm when sf = '0' and zf = '0' else s.ip;
          
          -- jge imm
          when op_jge =>
            s.ip := imm when sf = '0' or zf = '1' else s.ip;
          
          -- add rd, rs
          when op_add =>
            vd := vd + vs;
          
          -- adc rd, rs
          when op_adc =>
            vd := vd + vs + cf;
          
          -- sub rd, rs
          when op_sub =>
            vd := vd - vs;
          
          -- sbb rd, rs
          when op_sbb =>
            vd := vd - vs - cf;
          
          -- mul rd, rs
          when op_mul =>
            vd := vd * vs;
          
          -- imul rd, rs
          when op_imul =>
            vd := vd * vs;
          
          -- div rd, rs
          when op_div =>
            vd := vd / vs;
          
          -- idiv rd, rs
          when op_idiv =>
            vd := vd / vs;
          
          -- and rd, rs
          when op_and =>
            vd := vd and vs;
          
          -- or rd, rs
          when op_or =>
            vd := vd or vs;
          
          -- not rd
          when op_not =>
            vd := not vd;
          
          -- xor rd, rs
          when op_xor =>
            vd := vd xor vs;
          
          -- shl rd, rs
          when op_shl =>
            vd := shift_left(vd, vs);
          
          -- shr rd, rs
          when op_shr =>
            vd := shift_right(vd, vs);
          
          -- rol rd, rs
          when op_rol =>
            vd := shift_left(vd, vs);
          
          -- ror rd, rs
          when op_ror =>
            vd := shift_right(vd, vs);
          
          -- invalid
          when others =>
            s := st_halted;
        end case;
        s.flags(fl_carry) := cf;
        s.flags(fl_sign)  := sf;
        s.flags(fl_zero)  := zf;
        s.regs(i.rd) := vd;
        
      -- invalid state
      when others =>
        s <= st_halted;
    end case;
  end if;

  -- drive status
  xi <= i;
  xs <= s;

  -- drive outputs
  status <= s;
  minp.addr <= i.addr;
  minp.data <= i.data;
  minp.wr   <= i.wr;
end process;

end architecture bh;
