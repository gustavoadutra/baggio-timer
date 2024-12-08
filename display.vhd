library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display is
  Port ( 
    e : in integer range 0 to 15;
    d : out STD_LOGIC_VECTOR(6 downto 0)
  );
end display;

architecture Behavioral of display is
begin

  d <= "0000001" when e=0 else
       "1001111" when e=1 else
       "0010010" when e=2 else
       "0000110" when e=3 else
       "1001100" when e=4 else
       "0100100" when e=5 else
       "0100000" when e=6 else
       "0001111" when e=7 else
       "0000000" when e=8 else
       "0000100" when e=9 else
       "0001000" when e=10 else
       "1100000" when e=11 else
       "0110001" when e=12 else
       "1000010" when e=13 else
       "0110000" when e=14 else
       "0111000";


end Behavioral;
