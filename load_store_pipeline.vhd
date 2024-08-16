library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.iitb_risc_lib.all;

entity load_store_pipeline is
    port (
        pc_in           : in std_logic_vector(15 downto 0);
        op_code         : in std_logic_vector(3  downto 0);
        operand_1_value : in std_logic_vector(15 downto 0);
        operand_2_value : in std_logic_vector(15 downto 0);
        imm6            : in std_logic_vector(5  downto 0);
        destination_in  : in std_logic_vector(2  downto 0);
        valid_operation_in : in std_logic;
        
        pc_op           : out std_logic_vector(15 downto 0);
        destination_op  : out std_logic_vector(15  downto 0);
        address  : out std_logic_vector(15  downto 0);
        op_code_out  : out std_logic_vector(3  downto 0);
        operand_value   : out std_logic_vector(15  downto 0);
        mem_reg   : out std_logic;
        valid_operation_op : out std_logic
    );
end load_store_pipeline;

architecture behavorial of load_store_pipeline is
begin
pc_op <= pc_in;
address <= operand_2_value + imm6;
operand_value <= operand_1_value;
valid_operation_op <= valid_operation_in;
op_code_out <= op_code;
mem_reg_process:process(op_code)
begin
	if op_code = "0100" then
		 mem_reg <= '1';
         destination_op(2 downto 0) <= destination_in;
         destination_op(15 downto 3) <= (others => '0');
	else
		 mem_reg <= '0';
         destination_op <= operand_2_value + imm6 ;
	end if; 
end process;

end architecture behavorial;