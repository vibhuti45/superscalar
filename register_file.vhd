library ieee;
use std.textio.all; 
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.iitb_risc_lib.all;

entity register_file is
    port (
        -- clock reset
        clock : in std_logic;
        reset : in std_logic;

        -- pc read 
        pc_write_select :in std_logic;
        pc_input : in std_logic_vector(15 downto 0);
        pc_output : out std_logic_vector(15 downto 0);

        -- Operand to value/tag -- for source
        source_operands1_in : in operand_array(no_operand_1_read_ports - 1 downto 0);
        source_operands2_in : in operand_array(no_operand_2_read_ports - 1 downto 0);

        source_operand_1_value : out word_array(no_operand_1_read_ports - 1 downto 0);
        source_operand_1_value_valid : out bit_array(no_operand_1_read_ports - 1 downto 0);

        source_operand_2_value : out word_array(no_operand_2_read_ports - 1 downto 0);
        source_operand_2_value_valid : out bit_array(no_operand_2_read_ports - 1 downto 0);

        -- Operand to tag      -- for destinaltion
        destination_operand_in : in operand_array(no_reg_read_to_destination_tag_ports - 1 downto 0);
        destination_operand_in_valid : in bit_array(no_reg_read_to_destination_tag_ports - 1 downto 0);
        destination_operand_out : out operand_array(no_reg_read_to_destination_tag_ports - 1 downto 0);

        -- ARF data write port
        arf_data : in std_logic_vector(15 downto 0);
        arf_address : in std_logic_vector(2 downto 0);
        arf_tag     : in std_logic_vector(tag_size-1 downto 0);
        arf_write_valid : in std_logic;

        -- RRF data write port
        rrf_data : in word_array(total_no_pipelines - 1 downto 0);
        rrf_tag     : in word_array(total_no_pipelines - 1 downto 0);
        rrf_valid : in bit_array(total_no_pipelines - 1 downto 0)

    );
end register_file;

architecture behavorial of register_file is
    type arf_entry is record
        busy: std_logic;
        data   : std_logic_vector(15 downto 0);
        tag    : std_logic_vector(tag_size-1 downto 0);
    end record;

    type rrf_entry is record
        valid  : std_logic;
        busy  : std_logic;
        data   : std_logic_vector(15 downto 0);
    end record;

    type arch_register_file_array is array (0 to 7) of arf_entry;
    type phys_register_file_array is array (0 to rrf_size-1) of rrf_entry;

    signal tag_pointer : integer := 0;

    signal arch_register_file : arch_register_file_array := ((busy => '0', data => x"0000", tag => (others => '0')),
                                                            (busy => '0', data => x"0001", tag => (others => '0')),
                                                            (busy => '0', data => x"0002", tag => (others => '0')),
                                                            (busy => '0', data => x"0003", tag => (others => '0')),
                                                            (busy => '0', data => x"0004", tag => (others => '0')),
                                                            (busy => '0', data => x"0005", tag => (others => '0')),
                                                            (busy => '0', data => x"0006", tag => (others => '0')),
                                                            (busy => '0', data => x"0007", tag => (others => '0')));
    signal phys_register_file : phys_register_file_array := (others => (valid => '0', busy => '0', data => x"0000"));

    signal flag_00 : std_logic:='1'; 

begin
    -- pc_read:process(clock, arch_register_file(0).data)
    -- begin
        pc_output <= arch_register_file(0).data;
    -- end process pc_read;

    arf_register_write:process(clock, reset,arf_data, arf_tag, pc_input, destination_operand_in, destination_operand_in_valid)
    begin
        if reset = '1' then
            arf_reset_loop : for i in 0 to arf_size - 1 loop
                arch_register_file(i).busy <= '0';
                arch_register_file(i).data <= x"0000";
            end loop arf_reset_loop;
        else
            if falling_edge(clock) then
                if pc_write_select = '1' then
                    arch_register_file(0).data <= arf_data;
                    if arch_register_file(0).tag = arf_tag then
                        arch_register_file(0).busy <= '0';
                    else
                        arch_register_file(0).busy <= '1';
                    end if;
                else
                    arch_register_file(0).data <= pc_input;
                    if arf_write_valid = '1' then
                        arch_register_file(to_integer(unsigned(arf_address))).data <= arf_data;
                        
                        if arch_register_file(to_integer(unsigned(arf_address))).tag = arf_tag then 
                            arch_register_file(to_integer(unsigned(arf_address))).busy <= '0';
                        else
                            arch_register_file(to_integer(unsigned(arf_address))).busy <= '1';
                        end if;
                    end if;

                    for i in 0 to no_reg_read_to_destination_tag_ports - 1 loop
                        if destination_operand_in_valid(i) = '1' then
                            arch_register_file(to_integer(unsigned(destination_operand_in(i)))).busy <= '1';
                        end if;
                    end loop;
                end if;
                
                for i in 0 to no_reg_read_to_destination_tag_ports - 1 loop
                    if destination_operand_in_valid(i) = '1' then
                        arch_register_file(to_integer(unsigned(destination_operand_in(i)))).tag <= std_logic_vector(to_unsigned((tag_pointer + i) mod rrf_size, tag_size));
                        tag_pointer <= (tag_pointer + i + 1) mod rrf_size;
                    end if;
                end loop;
            end if;
        end if;
    end process arf_register_write;

    tag_read_process:process(clock, destination_operand_in)
    begin
        for i in 0 to no_reg_read_to_destination_tag_ports - 1 loop
            if destination_operand_in_valid(i) = '1' then
                destination_operand_out(i) <= std_logic_vector(to_unsigned((tag_pointer + i) mod rrf_size, tag_size));
            else
                destination_operand_out(i) <= (others => '0');
			end if;
        end loop;
    end process tag_read_process;

    rrf_register_write:process(clock)
    begin
        if reset = '1' then
            rrf_reset_loop: for i in 0 to rrf_size - 1 loop
                phys_register_file(i).data <= x"0000";
                phys_register_file(i).busy <= '0';
                phys_register_file(i).valid <= '0';
            end loop rrf_reset_loop;
        else
            if falling_edge(clock) then
                for i in 0 to total_no_pipelines - 1 loop
                    if rrf_valid(i) = '1' then
                        phys_register_file(to_integer(unsigned(rrf_tag(i)(2 downto 0)))).data <= rrf_data(i);
                        phys_register_file(to_integer(unsigned(rrf_tag(i)(2 downto 0)))).busy <= '0';
                        phys_register_file(to_integer(unsigned(rrf_tag(i)(2 downto 0)))).valid <= '1';
                    end if;
                end loop;
            end if;
        end if;

    end process rrf_register_write;
    
    register_read_OPERAND1:process(source_operands1_in, arch_register_file, phys_register_file)
    begin
        for i in 0 to no_operand_1_read_ports - 1 loop
            if arch_register_file(to_integer(unsigned(source_operands1_in(i)))).busy = '0' then
                source_operand_1_value(i) <= arch_register_file(to_integer(unsigned(source_operands1_in(i)))).data;
                source_operand_1_value_valid(i) <= '1';
            else
                if phys_register_file(to_integer(unsigned(arch_register_file(to_integer(unsigned(source_operands1_in(i)))).tag))).busy = '0' and phys_register_file(to_integer(unsigned(arch_register_file(to_integer(unsigned(source_operands1_in(i)))).tag))).valid = '1'  then
                    source_operand_1_value(i) <= phys_register_file(to_integer(unsigned(arch_register_file(to_integer(unsigned(source_operands1_in(i)))).tag))).data;
                    source_operand_1_value_valid(i) <= '1';
                else
                    source_operand_1_value(i)(15 downto tag_size) <= (others => '1');
                    source_operand_1_value(i)(tag_size-1 downto 0) <= arch_register_file(to_integer(unsigned(source_operands1_in(i)))).tag;
                    source_operand_1_value_valid(i) <= '0'; 
                end if;
            end if;  
        end loop; 
    end process register_read_OPERAND1;

    register_read_OPERAND2:process(source_operands2_in, arch_register_file, phys_register_file)
    begin
        for i in 0 to no_operand_2_read_ports - 1 loop
            if arch_register_file(to_integer(unsigned(source_operands2_in(i)))).busy = '0' then
                source_operand_2_value(i) <= arch_register_file(to_integer(unsigned(source_operands2_in(i)))).data;
                source_operand_2_value_valid(i) <= '1';
            else
                if phys_register_file(to_integer(unsigned(arch_register_file(to_integer(unsigned(source_operands2_in(i)))).tag))).busy = '0' and phys_register_file(to_integer(unsigned(arch_register_file(to_integer(unsigned(source_operands2_in(i)))).tag))).valid = '1'  then
                    source_operand_2_value(i) <= phys_register_file(to_integer(unsigned(arch_register_file(to_integer(unsigned(source_operands2_in(i)))).tag))).data;
                    source_operand_2_value_valid(i) <= '1';
                else
                    source_operand_2_value(i)(15 downto tag_size) <= (others => '1');
                    source_operand_2_value(i)(tag_size-1 downto 0) <= arch_register_file(to_integer(unsigned(source_operands2_in(i)))).tag;
                    source_operand_2_value_valid(i) <= '0'; 
                end if;
            end if;  
        end loop; 
    end process register_read_OPERAND2;

    -- sim_process:process(clock)
    -- variable out_line :line;
    -- variable cycle_count: integer:= 0;
    -- file output_file : text open write_mode is "../../sim/register_file.txt";
    -- begin
    --     if falling_edge(clock) then
    --         cycle_count := cycle_count + 1; 
    --         write(output_file, "Cycle : "); 
    --         write(output_file, integer'image(cycle_count));  
    --         write(out_line, LF); 
    --         writeline(output_file, out_line);


    --         write(output_file, "PC/R0 : "); 
    --         write(output_file, integer'image(to_integer(unsigned(arch_register_file(0).data)))); 

    --         write(out_line, LF); 
    --         writeline(output_file, out_line);

    --         write(output_file, "Architecture Register File"); 
    --         write(output_file, "                          "); 
    --         write(output_file, "Physical Register File    "); 
    --         write(out_line, LF); 
    --         writeline(output_file, out_line);

    --         write(output_file, "R   | Data | tag | busy   "); 
    --         write(output_file, "                          "); 
    --         write(output_file, "| Data | valid | busy "); 

    --         write(out_line, LF); 
    --         writeline(output_file, out_line);

    --         for i in 0 to arf_size - 1 loop
    --             write(output_file, "R"); 
    --             write(output_file, integer'image(i)); 
    --             write(output_file, "  |  "); 
    --             write(output_file, integer'image(to_integer(unsigned(arch_register_file(i).data)))); 
    --             write(output_file, "  |  "); 
    --             write(output_file, integer'image(to_integer(unsigned(arch_register_file(i).tag)))); 
    --             write(output_file, "  |  "); 
    --             write(output_file, to_string_std_logic(arch_register_file(i).busy)); 
    --             write(output_file, "                                 "); 
    --             write(output_file, integer'image(to_integer(unsigned(phys_register_file(i).data))));
    --             write(output_file, "  |  "); 
    --             write(output_file, to_string_std_logic(phys_register_file(i).valid)); 
    --             write(output_file, "  |  "); 
    --             write(output_file, to_string_std_logic(phys_register_file(i).busy)); 
    --             write(out_line, LF); 
    --             writeline(output_file, out_line);   
    --         end loop;

    --         write(out_line, LF); 
    --         writeline(output_file, out_line);  

    --     end if;
    -- end process sim_process;
end architecture behavorial;