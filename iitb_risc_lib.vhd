library ieee;
use ieee.STD_LOGIC_1164.ALL;
use ieee.STD_LOGIC_ARITH.ALL;
use ieee.STD_LOGIC_UNSIGNED.ALL;

package iitb_risc_lib is
    type word_array is array (integer range <>) of std_logic_vector (15 downto 0);
    type instruction_array is array (integer range <>) of std_logic_vector (11 downto 0);
    type byte_array is array (integer range <>) of std_logic_vector (7 downto 0);
    type nibble_array is array (integer range <>) of std_logic_vector (3 downto 0);
    type operand_array is array (integer range <>) of std_logic_vector (2 downto 0);
    type imm6 is array (integer range <>) of std_logic_vector (5 downto 0);
    type imm9 is array (integer range <>) of std_logic_vector (8 downto 0);
    type bit_array is array (integer range <>) of std_logic;
    
    constant no_al_pipelines : integer := 2;
    constant no_ls_pipelines : integer := 1;
    constant total_no_pipelines : integer := no_al_pipelines + no_ls_pipelines;
    
    constant fetch_width : integer := 2;
    constant ir_fetch_buffer_size : integer := fetch_width;
    constant ir_decoder_size : integer := fetch_width;
    constant decoder_buffer_size : integer := fetch_width;
    constant rs_input_size : integer := fetch_width;
    constant rs_output_size : integer := total_no_pipelines;
    
    constant rs_size : integer := 8;
    constant arf_size : integer := 8;
    constant rrf_size : integer := 8;
    constant rob_size : integer := 8;

    constant tag_size : integer := 3;
    constant no_operand_1_read_ports : integer := fetch_width;
    constant no_operand_2_read_ports : integer := fetch_width;
    constant no_reg_read_to_destination_tag_ports : integer := fetch_width;

    -- functions 
    function to_string(x: string) return string;
    function to_std_logic_vector(x: bit_vector) return std_logic_vector;
    function to_string_std_logic_vector(x: std_logic_vector) return string;
    function to_string_std_logic(x: std_logic) return string;
    
end package iitb_risc_lib;

package body iitb_risc_lib is

    -- create a constrained string 
    function to_string(x: string) return string is 
        variable ret_val: string(1 to x'length); 
        alias lx : string (1 to x'length) is x; 
    begin   
        ret_val := lx; 
        return(ret_val); 
    end to_string; 

    -- bit-vector to std-logic-vector and vice-versa 
    function to_std_logic_vector(x: bit_vector) return std_logic_vector is 
        alias lx: bit_vector(1 to x'length) is x; 
        variable ret_val: std_logic_vector(1 to x'length); 
    begin 
        for I in 1 to x'length loop 
            if(lx(I) = '1') then 
            ret_val(I) := '1'; 
            else 
            ret_val(I) := '0'; 
            end if; 
        end loop;  
        return ret_val; 
    end to_std_logic_vector; 

    function to_string_std_logic_vector(x: std_logic_vector) return string is 
        alias lx: std_logic_vector(1 to x'length) is x; 
        variable ret_val: string(1 to x'length); 
    begin 
        for I in 1 to x'length loop 
            if(lx(I) = '1') then 
            ret_val(I) := '1'; 
            else 
            ret_val(I) := '0'; 
            end if; 
        end loop;  
        return ret_val; 
    end to_string_std_logic_vector; 


    function to_string_std_logic(x: std_logic) return string is 
        alias lx: std_logic is x; 
        variable ret_val: string(0 to 0); 
    begin 
        if(lx = '1') then 
            ret_val := "1"; 
        else 
            ret_val := "0"; 
        end if;  
        return ret_val; 
    end to_string_std_logic; 
end package body iitb_risc_lib;