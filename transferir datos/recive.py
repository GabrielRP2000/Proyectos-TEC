import serial
import time
import gpxpy
import matplotlib.pyplot as plt

ser = serial.Serial('/dev/ttyUSB0', baudrate = 9600, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE, bytesize=serial.EIGHTBITS, timeout=0)

###########################################################################################################################################
def Enlazar_RF(): #realizar enlace de los RF
    while 1:
        Flag = ser.readline()
        time.sleep(0.1)
        #print("Flag:",Flag)
        
        ini = 0
        fin = 0
        cod1 = b''
        cod2 = b''
        cod3 = b''
        cod4 = b''
        #print("tamano pack:" , Flag)
        if len(Flag) != 0:
           for j in range(0,len(Flag)):
                cod1 = Flag[j:j+1]
                
                if j < len(Flag)-1:
                    cod2 = Flag[j+1:j+2]
                #print ("cod", cod1,cod2)
                if cod1 == b'l' and cod2 == b'l':
                    ini = j
                    cod3 = cod1
                    cod4 = cod2
        
        if len(Flag) > 7 and cod3 == b'l' and cod4 == b'l':# flag debe ser 22-00-1234
        
            NumCarac = Flag[ini+2:ini+4]
            NumPaq = Flag[ini+4:ini+8]
            rx_data = "3333"
            #print("Cod1:",cod1,"cod2:",cod2, "NumCaracter:", NumCarac)
            for j in range(0,5):
                ser.write(str.encode(rx_data)) # Responde con el codigo 3333 para enlazar
                time.sleep(0.2)
                print("Conectado")
            return NumPaq,NumCarac
            #print("Conectado")
            #time.sleep(5)
            break
        else: # Caso en el que no recibe respuesta de la Rasp
            cod1 = ""
            cod2 = ""
            print("No hay conexion")

###########################################################################################################################################
def reenviar_paquete(i): # Solicita Volver a enviar un paquete
    rx_data = "kk" + str(i).zfill(5) # va a enviar el numero del ultimo paquete recibido + codigo error = "4400000"
    #print("Reenvie:", i)
    ser.write(str.encode(rx_data))
    time.sleep(0.1)
######################################################################################################################################
# Recive la cantidad de paquetes y los guarda en la lista "paquetesCod"
def recibir_por_uart(infoPack):#manda [0]cantidad de paquetes, [1]cantidad de caracteres por paquete
    #print("cantidad de paquetes:",infoPack[0])
    NumPacks = int(infoPack[0])
    NumCaract = int(infoPack[1])
    paquetesCod = [""] * NumPacks  # Crear una lista de cadenas vacías con la misma longitud de paquetes a recivir
    i = 0
    contador = 0
    #reenviar_paquete(i)
    while i <= NumPacks:
        #time.sleep(0.1)
        pack = ser.readline()
        time.sleep(0.1)
        
        
        
        ini = 0
        cod1 = b''
        cod2 = b''
        cod3 = b''
        cod4 = b''
        #j = 0
        if len(pack) >= NumCaract:
            #print("tamano pack:" , pack)
            for j in range(0,len(pack)):
                cod1 = pack[j:j+1]
               # print ("cod", cod1)
                if j < len(pack)-1:
                    cod2 = pack[j+1:j+2]
                if cod1 == b'g' and cod2 == b'g' and j == 0:
                    ini = j
                    cod3 = cod1
                    cod4 = cod2
            Mipack = pack[ini:ini+NumCaract+2]
        
        Np1 = NumCaract + 2 # a partir de donde el numero del pack
        Np2 = NumCaract + 6 # seis porque es la parte donde va a ir numero del pack
    
        print("Paquete recbido:",pack)
        
        if len(Mipack) >= 14 and len(Mipack) != b'' and cod3 == b'g' and cod4 == b'g': # and ini+Np2 - NumCaract <= NumCaract:  # or i == paquetes:
            
            #if pack != b'':
           
            
            #print("imprimir:",pack)#,"numPack:",int(pack[Np1:Np2],16),"numWhile:",i)
            #print(pack,"cod1:",cod1,"cod2:",cod2)                                                 # gg-123456789012-cdef = 20
            #print("mipack",int(pack[ini+Np1:ini+Np2],16))
            if int(pack[ini+Np1:ini+Np2],16) == i: # verifica si el numero de paquete es igual al espacio de la lista a rellenar 
                if contador == 0:
                    pack1 = Mipack
                    contador += 1
                    #print("entro:",pack, " Contador:", contador)
                elif contador == 1:
                    pack2 = Mipack
                    paquetesCod[i] = ""
                    #paquetesCod[i] = compara(pack[:24],contador)
                    if pack1 == pack2:
                        #print("pack1:", pack1, " pack2:", pack2)
                        paquetesCod[i] = pack1[2:NumCaract+2]
                        print("Paquete Guardado:", paquetesCod[i])
                        pack1 = pack2 = b''
                        i += 1
                        reenviar_paquete(i)
                        time.sleep(0.1)
                        contador = 0
                    else:
                        contador += 1
                    porcentaje = (i/NumPacks)*100
                    print("Porcentaje:", round (porcentaje, 2))
                elif contador == 2: # caso de error en 2 paquetes se solicita reenvio de paquetes
                    reenviar_paquete(i)
                    print("Paquetes corruptos")
                    contador = 0
            elif i == NumPacks:
                print("Transmision Completada")
                break
            else: # En caso de problemas solicita que se le envie a partir del ultimo paquete guardado
                #print(" reenvie:", i)
                reenviar_paquete(i)
        else:
            i = i
            cod1 = ""
            cod2 = ""
            reenviar_paquete(i)
            #print("No se recibe informacion")
            
    return paquetesCod
                
###########################################################################################################################################
def decodificar(paquetesCod):# Recibe una lista de paquetes en hexadecimal y los decodifica a caracteres
    PackDecod = [""] * len(paquetesCod)
    for i in range(0,len(paquetesCod)):
        hexadecimal = paquetesCod[i]
        # Decodificar los bytes a una cadena
        cadena_hexadecimal = hexadecimal.decode('utf-8')

        # Convertir los valores hexadecimales a caracteres
        caracteres = [chr(int(cadena_hexadecimal[i:i+2], 16)) for i in range(0, len(cadena_hexadecimal), 2)]

        # Unir los caracteres en una sola cadena
        cadena_caracteres = ''.join(caracteres)
        PackDecod[i] = cadena_caracteres

#print("Cadena original en hexadecimal:", hexadecimal)
    print("Cadena en caracteres:", PackDecod)
    return PackDecod

###########################################################################################################################################

def CrearGpx(Pack,Archivo):
    cadenas_completas = ''.join(Pack)
    # Escribir la cadena en un archivo GPX
    nombre_archivo = Archivo
    with open(nombre_archivo, 'w') as archivo:
        archivo.write(cadenas_completas)
    
    for i in range(0,5):
        rx_data = '6666' # va a enviar el numero del ultimo paquete recibido + codigo error = "0000004444"
        ser.write(str.encode(rx_data))
        time.sleep(0.1)
    print("Archivo guardado correctamente")
    
###########################################################################################################################################
def mapearGpx(Archivo):
    # Cargar el archivo GPX
    gpx_file = open(Archivo, 'r')
    gpx = gpxpy.parse(gpx_file)

    # Obtener las coordenadas de la ruta
    coordenadas = []
    for track in gpx.tracks:
        for segment in track.segments:
            for point in segment.points:
                coordenadas.append((point.latitude, point.longitude))

    # Mostrar la ruta en un gráfico
    latitudes, longitudes = zip(*coordenadas)
    plt.figure(figsize=(10, 6))
    plt.plot(longitudes, latitudes, '-o', markersize=4)
    plt.xlabel('Longitud')
    plt.ylabel('Latitud')
    plt.title('Ruta GPX')
    plt.grid(True)
    plt.show()
###########################################################################################################################################

#realizar enlace de los RF
infoPack = Enlazar_RF() #manda numero de paquetes y cantidad de caracteres por paquete
#print('info',infoPack)
# Recibe por UART
paquetesCod = recibir_por_uart(infoPack)

#decodifica la lista de paquetes de hexadecimal a caracteres
Pack = decodificar(paquetesCod)

Archivo = '/home/gabriel/Escritorio/Fin.gpx'
#Crea el archivo .GPX en el directorio
CrearGpx(Pack,Archivo)

#Grafica el archivo .GPX
mapearGpx(Archivo)
