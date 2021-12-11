Library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

--/*
-- * El bloque Control Disponible debe constantemente estar chechando las señales
-- * activas de los temporizadores(0 libre, 1 ocupado) y mostrar en casillaDisp una casilla sugerida
-- * donde se pueda estacionar. Si se detecta un flanco de subida en la señal entraAuto
-- * entonces se debe mandar el InicioTemp # respectivo a la casillaDisp sugerida
-- * 
--*/

entity ControlDisponible is

	Port ( clk50MHz : in STD_LOGIC;
			 entraAuto: in STD_LOGIC;
			 TempActivo1: in STD_LOGIC;
			 TempActivo2: in STD_LOGIC;
			 TempActivo3: in STD_LOGIC;
			 TempActivo4: in STD_LOGIC;
			 InicioTemp1: out STD_LOGIC;
			 InicioTemp2: out STD_LOGIC;
			 InicioTemp3: out STD_LOGIC;
			 InicioTemp4: out STD_LOGIC;
			 casillaDisponible: out STD_LOGIC_VECTOR(2 downto 0)
			 );
end ControlDisponible;

architecture behavioral of ControlDisponible is 
	
	signal InicioTemp1_aux : std_logic;
	signal InicioTemp2_aux : std_logic;
	signal InicioTemp3_aux : std_logic;
	signal InicioTemp4_aux : std_logic;
	signal casillaDisp: integer range 0 to 4:=0;
	signal bandera_anterior : std_logic; 
	signal bandera_sinc : std_logic;
	signal bandera_nsinc : std_logic;
begin 

	revisaTemp : process (clk50MHz)
	begin 
		if rising_edge(clk50MHz) then
			--[Nota] tal vez revisar con menos frecuencia
			
			if TempActivo1 ='0' then -- esta disponible 1?
				casillaDisp<=1;
			elsif TempActivo2 ='0' then -- esta disponible 2?
				casillaDisp<=2;
			elsif TempActivo3 ='0' then -- esta disponible 3?
				casillaDisp<=3;
			elsif TempActivo4 ='0' then -- esta disponible 4?
				casillaDisp<=4;
			else  -- No hay disponible
				casillaDisp<=0;
			end if;
		end if;
	end process revisaTemp; 
	
	deco : process(clk50MHz)
	begin
		if rising_edge(clk50MHz) then
			if casillaDisp=1 then
				casillaDisponible <= "001";
			elsif casillaDisp =2 then
				casillaDisponible <= "010";
			elsif casillaDisp =3 then
				casillaDisponible <= "011";
			elsif casillaDisp =4 then
				casillaDisponible <= "100";
			elsif casillaDisp=0 then
				casillaDisponible <= "000";
			else 
				casillaDisponible <= "000";
			end if;
		end if;
	end process deco;
	
	beginCasillaDisp: process(clk50MHz)
	 variable banderaGuarda : std_LOGIC := '0';
	 variable banderaEmpieza : std_LOGIC :='0';
	 variable contadorGuarda : integer:=0;
	begin 
	  if rising_edge(clk50MHz) then 
	       
			if(bandera_anterior = '0' and bandera_sinc = '1') then -- flanco de subida de entraAuto
					-- Hacer flanco de subida a la casilla correspondiente
					-- Las demás en cero
				if casillaDisp=1 then
					banderaGuarda:='1';
					InicioTemp1_aux<='1';
					InicioTemp2_aux<='0';
					InicioTemp3_aux<='0';
					InicioTemp4_aux<='0';
					
				elsif casillaDisp =2 then
					banderaGuarda:='1';
					InicioTemp1_aux<='0';
					InicioTemp2_aux<='1';
					InicioTemp3_aux<='0';
					InicioTemp4_aux<='0';
					
				elsif casillaDisp =3 then
					banderaGuarda:='1';
					InicioTemp1_aux<='0';
					InicioTemp2_aux<='0';
					InicioTemp3_aux<='1';
					InicioTemp4_aux<='0';
					
				elsif casillaDisp =4 then
					banderaGuarda:='1';
					InicioTemp1_aux<='0';
					InicioTemp2_aux<='0';
					InicioTemp3_aux<='0';
					InicioTemp4_aux<='1';
				else 
					banderaGuarda:='1';
					InicioTemp1_aux<='0';
					InicioTemp2_aux<='0';
					InicioTemp3_aux<='0';
					InicioTemp4_aux<='0';
				end if;
				
				if contadorGuarda < 25000000 and banderaGuarda = '1' then
					contadorGuarda:=contadorGuarda+1;			
				else
					banderaGuarda:='0';
					contadorGuarda:=0;
				end if;
				
				if banderaGuarda ='1' then
					 InicioTemp1<=InicioTemp1_aux;
					 InicioTemp2<=InicioTemp2_aux;
					 InicioTemp3<=InicioTemp3_aux;
					 InicioTemp4<=InicioTemp4_aux;
				elsif banderaGuarda ='0' then 
					 InicioTemp1<='0';
					 InicioTemp2<='0';
					 InicioTemp3<='0';
					 InicioTemp4<='0';
				end if;
				
			end if;
			
			bandera_anterior<=bandera_sinc;
			bandera_sinc<=bandera_nsinc;
			bandera_nsinc<=entraAuto;
	  
	  end if;
	
	end process;

	
end behavioral;