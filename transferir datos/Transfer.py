import serial
import time

ser = serial.Serial('/dev/ttyS0', baudrate = 9600, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE, bytesize=serial.EIGHTBITS, timeout=0)

###########################################################################################################################################
def leer_archivo_gpx(nombre_archivo): # Para leer un archivo gpx
    with open(nombre_archivo, 'r') as file:
        contenido = file.read()
    return contenido
###########################################################################################################################################
def dividir_en_paquetes(info):
    longitud_paquete = 6
    paquetes = [''.join(hex(ord(caracter))[2:].zfill(2) for caracter in info[i:i+longitud_paquete]) for i in range(0, len(info), longitud_paquete)]
    
    pack = paquetes[len(paquetes)-1]
    cadena = len(pack)
    newPack = pack[:cadena]
    #print("paquetes:",pack)
    
    while cadena < longitud_paquete*2: # Para rellenar y alcanzar los caracteres por pack
        #print("New:",newPack)
        #time.sleep(1)
        newPack = newPack + "20"
        cadena += 2
    paquetes[len(paquetes)-1] = newPack
    #print("paquetes:",paquetes[len(paquetes)-1] , "new:", newPack)
    return paquetes
 
###########################################################################################################################################
def Enlazar_RF(paquetes): #realizar enlace de los RF
    #capacidad envio en bits = (NumPacks/2)*8 =
    #capacidad maxima definida por los seis caracteres de numeracion
    #MaxCapacidad = 16^4*6 = 65 535*6caracteres = 393,210 kBytes donde CQ = 35,3 kBytes
    if len(paquetes) < 65535: 
        while 1:# Enviar constantemente la cantidad de paquetes a enviar y un codigo, max 999 999
            NumCarac = len(paquetes[1])
            rx_data = "ll" + str(NumCarac) + str(len(paquetes)).zfill(4) # 33-22-1234-33
            ser.write(str.encode(rx_data))
            time.sleep(0.1)  # Espera breve entre paquetes para evitar saturación
            
            Flag = ser.readline()
            time.sleep(0.1)
            #print("Flag:",Flag)
            
            if len (Flag) != 0:
                #print ("tamano Flag", Flag)
                for j in range (0,len(Flag)):
                    cod1 = Flag[j:j+1]
                    if j < len(Flag)-1:
                        cod2 = Flag[j+1:j+2]
                    if cod1 == b'4' and cod2 == b'4':
                        ini = j
                    
            if Flag == b'3333':
                print("Conectado")
                #time.sleep(3)
                break
            else: # Caso en el que no recibe respuesta de la Rasp
                print("No hay conexion")
    else:
        print("Tamano maximo de archivo superado")
    return Flag
###########################################################################################################################################
def reenviar_paquete(i): #Volver a enviar un paquete
    Flag = ser.readline()   # va a recibir numero del ultimo paquete recibido + codigo error = "44-00000-55"
    time.sleep(0.1)
    
    ini = 0
    
    #print(Flag)
    cod1 = b''
    cod2 = b''
    cod3 = b''
    cod4 = b''


   

    
    if len(Flag) >= 7 and Flag != b'':
        for j in range (0,len(Flag)):
            cod1 = Flag[j:j+1]
            
            if j < len(Flag)-1:
               
                cod2 = Flag[j+1:j+2]
                
            if cod1 == b'k' and cod2 == b'k'and j==0:
                ini = j
                cod3 = cod1
                cod4 = cod2
                
                
        if cod3 == b'k' and cod4 == b'k':
            
            NumPaq = int(Flag[ini+2:ini+7])
            Flag = NumPaq
            ini = 0
        #time.sleep(0.1)
#        print("Reenviando:", NumPaq)
        
            return Flag 
    
    if cod3 == b'6' and cod4 == b'6':
        return 6666
    
    else:
        #time.sleep(0.1)
        return i

                

######################################################################################################################################
# enviar 4 paquetes y continuar con el siguiente, revisa si receptor necesita que vuelva a enviar paquete
def enviar_por_uart(paquetes):
    paquetesCod = [""] * len(paquetes)  # Crear una lista de cadenas vacías con la misma longitud que paquetes
    i = 0
    while 1:
        if i < len(paquetes):
            #print("contador:",i)
            iHex = str(hex(i))[2:]
            #print("contador:",iHex)
            paquetesCod[i] = ""
            paquetesCod[i] = "gg"+ paquetes[i] + iHex.zfill(4) # agrega el numero de paquete en los ultimos 4 espacios
            #for j in range(0,3):
            
            
            
            ser.write(paquetesCod[i].encode())#Espera breve entre paquetes para evitar saturación
            time.sleep(0.1)
            
        
            print("Contenido del paquete",(paquetesCod[i]))
            
            
            i = reenviar_paquete(i)
            
            #i += 1
            porcentaje = (i/len(paquetes))*100
            print ("Porcentaje:", round(porcentaje,2))
        elif i == 6666:
            print("Fin de transmision")
            break
            
        else:
            i -= 1
        
         
###########################################################################################################################################

# Lee el archivo .gpx
datos_gpx = leer_archivo_gpx('/home/pi/Desktop/peque1.gpx')#peque.gpx')

# Dividir en paquetes de 24 caracteres
paquetes = dividir_en_paquetes(datos_gpx)

#realizar enlace de los RF
Enlazar_RF(paquetes)

# Enviar por UART
enviar_por_uart(paquetes)

# enviar los paquetes hasta que reciba una senal de que ya puede continuar con el siguiente, de ser asi no necesita usar ultimos 6 caracteres para numerar

