library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity contador is
    Port(
        clock : in STD_LOGIC;
        d0 : out STD_LOGIC_VECTOR (6 downto 0) := "0000001";  -- Display
        selector : out STD_LOGIC_VECTOR(3 downto 0) := "1110";  -- Controla quais displays são ativados
        botaoA : in STD_LOGIC;  -- Botão A
        botaoB : in STD_LOGIC;  -- Botão B
        botaoC : in STD_LOGIC;  -- Botão C
        botaoD : in STD_LOGIC;  -- Botão D
        botaoE : in STD_LOGIC;  -- Botão E
        led : out STD_LOGIC  -- LED de controle
    );
end contador;

--100Mhz




architecture Behavioral of contador is

	signal contador : integer range 0 to 100e4 := 0;
	signal segundo_dez : integer range 0 to 9 := 0;
	signal segundo_uni : integer range 0 to 12 := 0;
	signal decimo : integer range 0 to 9 := 0;
	signal centesimo : integer range 0 to 9 := 0;
	signal conta_ate4 : integer range 0 to 4 := 0;
	signal entrada : integer range 0 to 9 := 0;
	signal clk100hz : STD_LOGIC := '0';
	signal cont : integer range 0 to 100e6;
	signal btD  : STD_LOGIC;
	signal btE  : STD_LOGIC;
	signal carr : integer range -1 to 1;



	component display is
		Port(
			e : in integer range 0 to 15;
			d : out STD_LOGIC_VECTOR(6 downto 0)
		);
	end component;
	
	
	component debounce is
		generic (max : integer := 10e6); -- 1 milh�o = 10ms em clock de 100Mhz
		Port( 
			  clk : in  STD_LOGIC;
           botao : in  STD_LOGIC;
           result : out  STD_LOGIC);
		end component;

begin

	u1: display port map(entrada, d0);
	d1:debounce port map(clock, botaoD, btD);
	d2:debounce port map(clock, botaoE, btE);

	process(clock, btD, btE)
	begin
		carr <= 0;
	
	
		if rising_edge(clock) then
			if contador=100e4 then
				contador <= 0;
				
				if  botaoB = '1' then
								segundo_uni <= 0;
								segundo_dez <= 0;
								decimo <= 0;
								centesimo <= 0;					
				--end if;
				
				
				elsif centesimo = 9 then
					centesimo <= 0;

						if decimo = 9 then
							decimo <= 0;
							-- Limitador de 99 segundos para o contador
							if (segundo_uni = 9 and segundo_dez = 9) then
								segundo_uni <= 0;
								segundo_dez <= 0;
								decimo <= 0;
								centesimo <= 0;
							else
								-- Verifica se botao A ou C esta pressionado
								if botaoA = '1' then
									segundo_uni <= (segundo_uni + 3) mod 10;
									if ((segundo_uni + 3) mod 10) < 3 then
										-- Pega as dezenas do segundo_uni
										segundo_dez <= segundo_dez + 1;
										-- Pega as unidades do segundo
									end if;
									segundo_uni <= (segundo_uni + 3) mod 10;

								elsif botaoC = '1' then
									if segundo_uni = 0 then
										-- Segundos zerados
										if segundo_dez = 0 then
											led <= '1';
										else
											-- Se nao estiver zerado so decrementar a dezena
											-- e colocar em 9 a unidade
											segundo_uni <= 9;
											segundo_dez <= segundo_dez - 1;
										end if;
									else
										segundo_uni <= segundo_uni - 1;
									end if;
								else
									-- Sem botoes pressionados continuar soma
									led <= '0';
									if segundo_uni = 9 then
										segundo_uni <= 0;
										segundo_dez <= segundo_dez + 1;
									else
										segundo_uni <= segundo_uni + 1;
									end if;
								end if;
							end if;
						else
							decimo <= decimo + 1;
							
						end if;
					else
						centesimo <= centesimo + 1;
						
					end if;
				else
					contador <= contador + 1;
					
				end if;
				
				if btD = '1' then
            -- Incrementa o contador de segundos
            if segundo_uni = 9 then
                segundo_uni <= 0;
                if segundo_dez = 9 then
                    segundo_dez <= 0;  -- Se as dezenas chegarem a 9, resetamos
                else
                    segundo_dez <= segundo_dez + 1;  -- Incrementa as dezenas
                end if;
            else
                segundo_uni <= segundo_uni + 1;  -- Incrementa a unidade
            end if;
        elsif btE = '1' then
            -- Decrementa o contador de segundos
            if segundo_uni = 0 then
                if segundo_dez = 0 then
                    -- Se já estiver no zero, não faz nada
                    led <= '1';  -- Você pode adicionar um LED de erro, ou feedback
                else
                    segundo_dez <= segundo_dez - 1;  -- Decrementa as dezenas
                    segundo_uni <= 9;  -- Reconfigura as unidades para 9
                end if;
            else
                segundo_uni <= segundo_uni - 1;  -- Decrementa a unidade
            end if;
        end if;
				
				
				
				
				
			end if;
	end process;
	

	process(clock)
	begin
		if rising_edge(clock) then
			if cont = 10e3 then
				cont <= 0;
				clk100hz <= not clk100hz;
			else
				cont <= cont + 1;
			end if;
		end if;
	end process;

	process(clk100hz)
	begin
		if rising_edge(clk100hz) then
		
			if  botaoB = '1' then
				selector <= "1111";
		
			elsif conta_ate4 = 4 then
				conta_ate4 <= 0;
				selector <= "0111";
				entrada <= segundo_dez;
			else
				if conta_ate4 = 3 then
					selector <= "1011";
					entrada <= segundo_uni;
				elsif conta_ate4 = 2 then
					selector <= "1101";
					entrada <= decimo;
				else
					selector <= "1110";
					entrada <= centesimo;
				
				end if;

			conta_ate4 <= conta_ate4 + 1;
			end if;
		end if;
	end process;

end Behavioral;
