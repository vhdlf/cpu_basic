library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.pkg_bits.all;
use work.pkg_mem.all;
use work.pkg_cpu.all;



entity top is
port (
  clk:  in  std_logic;
  rst:  in  std_logic;
  run:  in  std_logic;
  mout: in  mem_output;
  minp: out mem_input;
  cout: out cpu_output
);
end entity top;



architecture bh of top is
  signal xi: cpu_internal;
begin

p_seq: process (clk, rst, run, xi)
  variable i: cpu_internal;
  variable m: mem_output;
  variable vw:  word1;
  variable vdw: dword1;
  variable vd, vs, imm: word;
  variable zf, cf, sf:  std_logic;
begin

  -- reset? clean up
  if rst = '1' then
    report "RESET" severity warning;
    i := xi;
    
    -- clean up
    i.state := st_halted;
    i.regs  := (others => (others => '0'));
    i.flags := (others => '0');
    i.ip    := (others => '0');
    i.op    := (others => '0');
    i.rd    := (others => '0');
    i.rs    := (others => '0');
    i.imm   := (others => '0');
    i.addr  := (others => '0');
    i.data  := (others => '0');
    i.buff  := (others => '0');
    i.wr    := '0';
    
    -- drive signals
    xi <= i;
    
    -- drive output
    minp.addr <= i.addr;
    minp.data <= i.data;
    minp.wr   <= i.wr;
    cout.state <= to_unsigned(cpu_state'pos(i.state), 4);
    cout.ip    <= i.ip(7 downto 0);
    cout.op <= i.op;
    cout.rd <= i.rd;
    cout.rs <= i.rs;
  
  -- run? do something
  elsif rising_edge(clk) then
    i := xi;
    m := mout;
    
    case i.state is
      -- was halted? start fetch
      when st_halted =>
        if run = '1' then i.state := st_fetch0; end if;
      
      -- request bytes 0-1
      when st_fetch0 =>
        i.addr  := i.ip(15 downto 0);
        i.state := st_fetch1;
      
      -- got bytes 0-1
      -- if short opcode, execute
      -- else request bytes 2-3
      when st_fetch1 =>
        i.op := m.data(7  downto 0);
        i.rd := m.data(11 downto 8);
        i.rs := m.data(15 downto 12);
        i.addr := i.addr + 2;
        case i.op is
          when OP_LOAD |
               OP_STORE |
               OP_MOVI |
               OP_JMP |
               OP_JZ |
               OP_JNZ |
               OP_JB |
               OP_JBE |
               OP_JG |
               OP_JGE =>
            i.ip    := i.ip + 6;
            i.state := st_fetch2;
          when others =>
            i.ip    := i.ip + 2;
            i.state := st_execute;
        end case;
      
      -- got bytes 2-3
      -- request bytes 4-5
      when st_fetch2 =>
        i.imm(15 downto 0) := m.data;
        i.addr  := i.addr + 2;
        i.state := st_fetch3;
      
      -- got bytes 4-5
      -- start execution
      when st_fetch3 =>
        i.imm(31 downto 16) := m.data;    
        i.addr  := i.addr + 2;
        i.state := st_execute;
      
      -- got bytes 0-1
      -- request bytes 2-3
      when st_load0 =>
        i.buff(15 downto 0) := m.data;
        i.addr  := i.addr + 2;
        i.state := st_load1;
      
      -- got bytes 2-3
      -- set dest register
      -- fetch next instruction
      when st_load1 =>
        i.buff(31 downto 16) := m.data;
        i.regs(to_integer(i.rd)) := i.buff;
        i.addr  := i.addr + 2;
        i.state := st_fetch0;
      
      -- wrote bytes 0-1
      -- send bytes 2-3
      when st_store0 =>
        i.data  := i.buff(31 downto 16);
        i.addr  := i.addr + 2;
        i.state := st_store1;
      
      -- wrote bytes 2-3
      -- stop writing
      -- fetch next instruction
      when st_store1 =>
        i.wr    := '0';
        i.state := st_fetch0;
      
      -- execute instruction
      when st_execute =>
        vd  := i.regs(to_integer(i.rd));
        vs  := i.regs(to_integer(i.rs));
        imm := i.imm;
        zf := i.flags(FL_ZERO);
        sf := i.flags(FL_SIGN);
        cf := i.flags(FL_CARRY);
        i.state := st_fetch0;
        
        case i.op is
          -- load rd, [rs+imm]
          when OP_LOAD =>
            report "load r" & str(i.rd) & ", [r" & str(i.rs) & " + " & hstr(imm) & "]" severity note;
            vw := '0' & vs + imm;
            i.addr  := vw(15 downto 0);
            i.state := st_load0;
          
          -- store [rd+imm], rs
          when OP_STORE =>
            report "store [r" & str(i.rd) & " + " & hstr(imm) & "], r" & str(i.rs) severity note;
            vw := '0' & vd + imm;
            i.addr  := vw(15 downto 0);
            i.buff  := vs;
            i.data  := i.buff(15 downto 0);
            i.wr    := '1';
            i.state := st_store0;
          
          -- movi rd, imm
          when OP_MOVI =>
            report "movi r" & str(i.rd) & ", " & hstr(imm) severity note;
            vd := imm;
          
          -- mov rd, rs
          when OP_MOV =>
            report "mov r" & str(i.rd) & ", r" & str(i.rs) severity note;
            vd := vs;
          
          -- cmp rd, rs
          when OP_CMP =>
            report "cmp r" & str(i.rd) & ", r" & str(i.rs) severity note;
            vw := '0' & vd - vs;
            i.flags := flags_word(vw);
          
          -- jmp imm
          when OP_JMP =>
            report "jmp " & hstr(imm) severity note;
            i.ip := imm;
          
          -- jz imm
          when OP_JZ =>
            report "jz " & hstr(imm) severity note;
            if zf = '1' then
              i.ip := imm;
            end if;
          
          -- jnz imm
          when OP_JNZ =>
            report "jnz " & hstr(imm) severity note;
            if zf = '0' then
              i.ip := imm;
            end if;
          
          -- jb imm
          when OP_JB =>
            report "jb " & hstr(imm) severity note;
            if sf = '1' and zf = '0' then
              i.ip := imm;
            end if;
          
          -- jbe imm
          when OP_JBE =>
            report "jbe " & hstr(imm) severity note;
            if sf = '1' or zf = '1' then
              i.ip := imm;
            end if;
          
          -- jg imm
          when OP_JG =>
            report "jg " & hstr(imm) severity note;
            if sf = '0' and zf = '0' then
              i.ip := imm;
            end if;
          
          -- jge imm
          when OP_JGE =>
            report "jge " & hstr(imm) severity note;
            if sf = '0' or zf = '1' then
              i.ip := imm;
            end if;
          
          -- add rd, rs
          when OP_ADD =>
            report "add r" & str(i.rd) & ", r" & str(i.rs) severity note;
            vw := '0' & vd + vs;
            vd := vw(31 downto 0);
            i.flags := flags_word(vw);
          
          -- adc rd, rs
          when OP_ADC =>
            report "adc r" & str(i.rd) & ", r" & str(i.rs) severity note;
            vw := '0' & vd + vs;
            if cf = '1' then vw := vw + 1; end if;
            vd := vw(31 downto 0);
            i.flags := flags_word(vw);
          
          -- sub rd, rs
          when OP_SUB =>
            report "sub r" & str(i.rd) & ", r" & str(i.rs) severity note;
            vw := '0' & vd - vs;
            vd := vw(31 downto 0);
            i.flags := flags_word(vw);
          
          -- sbb rd, rs
          when OP_SBB =>
            report "sbb r" & str(i.rd) & ", r" & str(i.rs) severity note;
            vd := '0' & vd - vs;
            if cf = '1' then vw := vw - 1; end if;
            vd := vw(31 downto 0);
            i.flags := flags_word(vw);
          
          -- mul rd, rs
          when OP_MUL =>
            report "mul r" & str(i.rd) & ", r" & str(i.rs) severity note;
            vdw := '0' & vd * vs;
            vd := vdw(31 downto 0);
            i.flags := flags_dword(vdw);
          
          -- imul rd, rs
          when OP_IMUL =>
            report "imul r" & str(i.rd) & ", r" & str(i.rs) severity note;
            vdw := '0' & vd * vs;
            vd := vdw(31 downto 0);
            i.flags := flags_dword(vdw);
          
          -- div rd, rs
          when OP_DIV =>
            report "div r" & str(i.rd) & ", r" & str(i.rs) severity note;
            vw := '0' & vd / vs;
            vd := vw(31 downto 0);
            i.flags := flags_word(vw);
          
          -- idiv rd, rs
          when OP_IDIV =>
            report "idiv r" & str(i.rd) & ", r" & str(i.rs) severity note;
            vw := '0' & vd / vs;
            vd := vw(31 downto 0);
            i.flags := flags_word(vw);

          -- inc rd
          when OP_INC =>
            report "inc r" & str(i.rd) severity note;
            vw := '0' & vd + 1;
            vd := vw(31 downto 0);
            i.flags := flags_word(vw);

          -- dec rd
          when OP_DEC =>
            report "dec r" & str(i.rd) severity note;
            vw := '0' & vd - 1;
            vd := vw(31 downto 0);
            i.flags := flags_word(vw);

          -- and rd, rs
          when OP_AND =>
            report "and r" & str(i.rd) & ", r" & str(i.rs) severity note;
            vw := '0' & vd and vs;
            vd := vw(31 downto 0);
            i.flags := flags_word(vw);
          
          -- or rd, rs
          when OP_OR =>
            report "or r" & str(i.rd) & ", r" & str(i.rs) severity note;
            vw := '0' & vd or vs;
            vd := vw(31 downto 0);
            i.flags := flags_word(vw);
          
          -- not rd
          when OP_NOT =>
            report "not r" & str(i.rd) severity note;
            vw := not '0' & vd;
            vd := vw(31 downto 0);
            i.flags := flags_word(vw);
          
          -- xor rd, rs
          when OP_XOR =>
            report "xor r" & str(i.rd) & ", r" & str(i.rs) severity note;
            vw := '0' & vd xor vs;
            vd := vw(31 downto 0);
            i.flags := flags_word(vw);
          
          -- shl rd, rs
          when OP_SHL =>
            report "shl r" & str(i.rd) & ", r" & str(i.rs) severity note;
            vd := shift_left(vd, to_integer(vs));
          
          -- shr rd, rs
          when OP_SHR =>
            report "shr r" & str(i.rd) & ", r" & str(i.rs) severity note;
            vd := shift_right(vd, to_integer(vs));
          
          -- rol rd, rs
          --when OP_ROL =>
          --  vd := shift_left(vd, to_integer(vs));
          
          -- ror rd, rs
          --when OP_ROR =>
          --  vd := shift_right(vd, to_integer(vs));
          
          -- invalid
          when others =>
            report "INVALID OPCODE" severity warning;
            i.state := st_halted;
        end case;
        -- i.flags(FL_CARRY) := cf;
        -- i.flags(FL_SIGN)  := sf;
        -- i.flags(FL_ZERO)  := zf;
        i.regs(to_integer(i.rd)) := vd;
        
      -- invalid state
      when others =>
        report "INVALID STATE" severity warning;
        i.state := st_halted;
    end case;
    
    -- drive status
    xi <= i;

    -- drive outputs
    minp.addr <= i.addr;
    minp.data <= i.data;
    minp.wr   <= i.wr;
    cout.state <= to_unsigned(cpu_state'pos(i.state), 4);
    cout.ip    <= i.ip(7 downto 0);
    cout.op <= i.op;
    cout.rd <= i.rd;
    cout.rs <= i.rs;
  end if;
end process;

end architecture bh;
