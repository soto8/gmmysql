/*
                                         Creador: soto8
*/
//Includes
#include <a_samp>
#include <a_mysql>
#include <streamer>
#include <sscanf2>
#include <YSI\y_ini>
#include <YSI/y_iterate>

//Datos MySQL
#define MySQL_SERVER "localhost"
#define MySQL_USER "root"
#define SQL_CONTRA ""
#define MySQL_PASS "gm2"
//Dialogos registro
#define DREGISTRO   0
#define DGENERO     1
#define DEDAD       2
#define DINGRESO    3

AntiDeAMX()
{
   new a[][] =
   {
      "Unarmed (Fist)",
      "Brass K"
   };
   #pragma unused a
}
//news
new MySQL;
//Enum
enum jInfo
{
    Contra[128],
	Admin,
	Genero,
    Edad,
    Ropa,
    Float:X,
    Float:Y,
    Float:Z,
    Float:Vida,
    Float:Chaleco,
    Faccion,
    Rango,
    Trabajo,
    Dinero,
    Int,
    VW,
    Nivel
}
new PlayersData[MAX_PLAYERS][jInfo];
//Stocks y funciones
stock SendClientMessageEx(playerid, color, const text[], {Float, _}:...)
{
	static
	    args,
	    str[144];
	if (( args = numargs()) == 3)
	{
        SendClientMessage(playerid, color, text);
	}
	else
	{
		while (--args >= 3)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit PUSH.S 8
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit LCTRL 4
		
		SendClientMessage(playerid, color, str);
		
		#emit RETN
	}
	return 1;
}
stock SendClientMessageToAllEx(color, const text[], {Float, _}:...)
{
	static
	    args,
	    str[144];

	if ((args = numargs()) == 2)
	{
	    SendClientMessageToAll(color, text);
	}
	else
	{
		while (--args >= 2)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit LOAD.S.pri 8
		#emit ADD.C 4
		#emit PUSH.pri
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		SendClientMessageToAll(color, str);

		#emit RETN
	}
	return 1;
}
stock SendClientMessageX(color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 8)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 8); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit ADD.C 4
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

        foreach (new i : Player)
		{
			if (PlayersData[i][Admin] >= 1) {
  				SendClientMessage(i, color, string);
			}
		}
		return 1;
	}
	foreach (new i : Player)
	{
		if (PlayersData[i][Admin] >= 1) {
			SendClientMessage(i, color, str);
		}
	}
	return 1;
}
stock InicioCamara(playerid)
{
	SetPlayerCameraPos(playerid, 1533.2587, -1763.7717, 73.6204);
	SetPlayerCameraLookAt(playerid, 1532.9288, -1762.8286, 73.0504);
	SetPlayerPos(playerid,1513.4531, -1782.2853, 68.0610);
	TogglePlayerControllable(playerid,0);
	return 1;
}
stock PlayerName(playerid)
{
	new nombre[MAX_PLAYER_NAME];
	GetPlayerName(playerid, nombre, sizeof(nombre));
	return nombre;
}
stock SendMessageFaction(fid, color, mensaje[]) //Enviar Mensaje a una facción
{
	for(new i = 0; i < MAX_PLAYERS; i++)
{
	if(PlayersData[i][Faccion] == fid)
{
	SendClientMessageEx(i,color,mensaje);
}
}
return 1;
}

strtok(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}
//Forward's
forward UserVerificated(playerid); //Verificar usuario
forward NewAccount(playerid); //Nueva cuenta al que un jugador ingresa por 1era vez
forward EnterPlayer(playerid); //Ingreso por 1era vez.
forward LoadAccount(playerid); //Cargar Cuenta
forward SaveAccount(playerid); //Crear Cuenta
forward RemoveMaps(playerid); //RemoverMapeos
forward LoadMaps(); //CargarMapeos
//
main()
{
	return soto8 ();
}

soto8()
{
	printf("Modo de juego creado por soto8");
	return 1;
}

public OnGameModeInit()
{
    AntiDeAMX();

	SetGameModeText("Roleplay");
	MySQL = mysql_connect(MySQL_SERVER,MySQL_USER,MySQL_PASS,MySQL_PASS);
   	print("Estableciendo conexión...");
	if(mysql_errno() != 0)
	{
    	print("No se ha podido establecer la conexión a la base de datos.");
	}
	else
	{
    	print("Conexión establecida correctamente.");
	}
	
	LoadMaps();
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
   RemoveMaps(playerid);
   new query[520],nombre[MAX_PLAYER_NAME];
   GetPlayerName(playerid, nombre, sizeof(nombre));
   mysql_format(MySQL, query, sizeof(query), "SELECT * FROM `cuentas` WHERE `Nombre`='%s'", nombre);
   mysql_pquery(MySQL, query, "UserVerificated","d", playerid);
   return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    SaveAccount(playerid);
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	new idx;
	new cmd[256];

	cmd = strtok(cmdtext, idx);

	if(strcmp(cmd, "/ayuda", true) == 0)
	{
    	return 1;
	}

	return 0;
}

public OnPlayerSpawn(playerid)
{
	if(GetPVarInt(playerid, "PuedeIngresar") == 0)
	{
	Kick(playerid);
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	//
	case DREGISTRO:
	{
        if(response)
		{
    		new contra[128];
     		ShowPlayerDialog(playerid, DGENERO, DIALOG_STYLE_MSGBOX, "Genero", "{ffffff}¿Qué genero es usted?.", "Masculino", "Femenino");
    		format(contra,sizeof(contra),"%s",inputtext);
    		PlayersData[playerid][Contra] = contra;
		}
		else
		{
		    Kick(playerid);
		}
    }
    //
	case DGENERO:
	{
		if(response)
		{
    		PlayersData[playerid][Genero] = 0;
	    	PlayersData[playerid][Ropa] = 46;
    		ShowPlayerDialog(playerid, DEDAD, DIALOG_STYLE_INPUT, "Edad", "{ffffff}Ingrese su edad\n\nMinimo 18 - Maximo 90.", "Continuar", "Cancelar");
		}
		else
		{
    		PlayersData[playerid][Genero] = 1;
    		PlayersData[playerid][Ropa] = 12;
    		ShowPlayerDialog(playerid, DEDAD, DIALOG_STYLE_INPUT, "Edad", "{ffffff}Ingrese su edad\n\nMinimo 18 - Maximo 90.", "Continuar", "Cancelar");
		}
	  }
	//
	case DEDAD:
	{
	     if(response)
		 {
	    	 if(strval(inputtext) < 18 || strval(inputtext) > 100) return ShowPlayerDialog(playerid, DEDAD, DIALOG_STYLE_INPUT, "Edad", "{ffffff}Ingrese su edad\n\n{FF0000}Minimo 18 - Maximo 90.", "Continuar", "Cancelar");
    		 PlayersData[playerid][Edad] = strval(inputtext);
	    	 SetSpawnInfo(playerid, 0, PlayersData[playerid][Ropa], 1484.1082, -1668.4976, 14.9159, 0.0000, 0,0,0,0,0,0);
     		 SetPVarInt(playerid, "PuedeIngresar", 1);
    		 SpawnPlayer(playerid);
    		 NewAccount(playerid);
	     }
		 else
		 {
	    	 Kick(playerid);
		 }
	}
	//
	case DINGRESO:
	{
        if(response)
		{
    		new query[520];
	    	mysql_format(MySQL,query,sizeof(query),"SELECT * FROM `cuentas` WHERE `Nombre`='%s' AND `Contra`='%s'",PlayerName(playerid),inputtext);
    		mysql_pquery(MySQL, query, "EnterPlayer","d", playerid);
		}
		else
		{
    		Kick(playerid);
		}
	}
	//
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
public UserVerificated(playerid)
{
   	new Rows;
    Rows = cache_get_row_count();
    if(!Rows)
    {
        InicioCamara(playerid);
    	ShowPlayerDialog(playerid, DREGISTRO, DIALOG_STYLE_INPUT, "Registro", "{ffffff}Bienvenido\n\nIngrese una contraseña para registrarse en nuestra base de datos.", "Registrar", "Cancelar");
	}
	else
	{
    	InicioCamara(playerid);
    	ShowPlayerDialog(playerid, DINGRESO, DIALOG_STYLE_INPUT, "Ingreso", "{ffffff}Bienvenido\n\nIngrese su contraseña para ingresar.", "Continuar", "Cancelar");
	}
	return 1;
}
public NewAccount(playerid)
{
	new query[520],aviso[125];
	mysql_format(MySQL, query, sizeof(query), "INSERT INTO `cuentas`(`Nombre`, `Contra`, `Ropa`, `X`, `Y`, `Z`, `Genero`, `Admin`, `Vida`, `Dinero`) VALUES ('%s','%s','%i','1484.1082', '-1668.4976', '14.9159','%i','100','100000')",
	PlayerName(playerid),
	PlayersData[playerid][Contra],
	PlayersData[playerid][Ropa],
	PlayersData[playerid][Genero],
	PlayersData[playerid][Admin]);
	mysql_query(MySQL, query);
	format(aviso,sizeof(aviso),"Cuenta creada: %s - Edad: %d - Genero: %d", PlayerName(playerid), PlayersData[playerid][Edad], PlayersData[playerid][Genero]);
	print(aviso);
	return 1;
}

public EnterPlayer(playerid)
{
    if(cache_get_row_count() == 0)
{
	ShowPlayerDialog(playerid, DINGRESO, DIALOG_STYLE_INPUT, "Ingreso", "¡Error!\n\nLa contraseña no es correcta.", "Continuar", "Cancelar");
}
    else
{
	PlayersData[playerid]       [Ropa] = cache_get_row_int(0, 3);
	PlayersData[playerid]       [X] = cache_get_row_float(0, 4);
	PlayersData[playerid]       [Y] = cache_get_row_float(0, 5);
	PlayersData[playerid]       [Z] = cache_get_row_float(0, 6);
	PlayersData[playerid]       [Genero] = cache_get_row_int(0, 7);
	PlayersData[playerid]       [Admin] = cache_get_row_int(0, 8);
	PlayersData[playerid]       [Vida] = cache_get_row_float(0, 9);
	PlayersData[playerid]       [Chaleco] = cache_get_row_float(0, 10);
	PlayersData[playerid]       [Faccion] = cache_get_row_int(0, 11);
	PlayersData[playerid]       [Rango] = cache_get_row_int(0, 12);
	PlayersData[playerid]       [Trabajo] = cache_get_row_int(0, 13);
	PlayersData[playerid]       [Dinero] = cache_get_row_int(0, 14);
	PlayersData[playerid]       [Int] = cache_get_row_int(0, 15);
	PlayersData[playerid]       [VW] = cache_get_row_int(0, 16);
	PlayersData[playerid]       [Edad] = cache_get_row_int(0, 17);
	SetPVarInt(playerid,        "PuedeIngresar", 1);
	LoadAccount(playerid);
}
    return 1;
}
public LoadAccount(playerid)
{
	SetSpawnInfo(playerid, 0, PlayersData[playerid][Ropa], PlayersData[playerid][X],PlayersData[playerid][Y],PlayersData[playerid][Z], 0.0000, 0,0,0,0,0,0);
	SpawnPlayer(playerid);
	SetPlayerHealth(playerid,PlayersData[playerid][Vida]);
	SetPlayerArmour(playerid,PlayersData[playerid][Chaleco]);
	GivePlayerMoney(playerid,PlayersData[playerid][Dinero]);
	SetPlayerVirtualWorld(playerid,PlayersData[playerid][VW]);
	SetPlayerInterior(playerid,PlayersData[playerid][Int]);
	SetPlayerSkin(playerid,PlayersData[playerid][Ropa]);
	return 1;
}
public SaveAccount(playerid)
{
	new query[520],Float:jX,Float:jY,Float:jZ,Float:hp,Float:chale,pVW,pInt;
	GetPlayerPos(playerid, jX, jY, jZ);
	GetPlayerHealth(playerid,hp);
	GetPlayerArmour(playerid,chale);
	PlayersData[playerid][VW] = GetPlayerVirtualWorld(playerid);
	PlayersData[playerid][Int] = GetPlayerInterior(playerid);
	pVW = GetPlayerVirtualWorld(playerid);
	pInt = GetPlayerInterior(playerid);
	mysql_format(MySQL, query, sizeof(query), "UPDATE `cuentas` SET `Ropa`='%i',`X`='%f',`Y`='%f',`Z`='%f',`Genero`='%i', `Admin`='%i', `Vida`='%f',`Chaleco`='%f' WHERE `Nombre`='%s'",
	PlayersData[playerid][Ropa],
	jX,
	jY,
	jZ,
	PlayersData[playerid][Genero],
	hp,
	chale,
	PlayerName(playerid));
	mysql_query(MySQL, query);
//
	mysql_format(MySQL, query, sizeof(query), "UPDATE `cuentas` SET `Edad`='%i', `Faccion`='%i', `Rango`='%i', `Trabajo`='%i', `Dinero`='%i' WHERE `Nombre`='%s'",
	PlayersData[playerid][Edad],
	PlayersData[playerid][Faccion],
	PlayersData[playerid][Rango],
	PlayersData[playerid][Trabajo],
	PlayersData[playerid][Dinero],
	PlayerName(playerid));
	mysql_query(MySQL, query);

	mysql_format(MySQL, query, sizeof(query), "UPDATE `cuentas` SET `VW`='%i', `Interior`='%i' WHERE `Nombre`='%s'",
	pVW,
	pInt,
	PlayerName(playerid));
	mysql_query(MySQL, query);

	return 1;
}
public OnQueryError(errorid, error[], callback[], query[], connectionHandle)
{
	switch(errorid)
	{
		case CR_SERVER_GONE_ERROR:
		{
			printf("Conexión perdida...");
			mysql_reconnect(connectionHandle);
		}
		case ER_SYNTAX_ERROR:
		{
			printf("Error en el sintaxis de la consulta: %s",query);
		}
	}
	return 1;
}

public LoadMaps()
{
	return 1;
}

public RemoveMaps(playerid)
{
	return 1;
}
