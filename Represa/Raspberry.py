import subprocess
import threading
import serial
import time
import re
from gpiozero import OutputDevice
import RPi.GPIO as GPIO

ser = serial.Serial('/dev/ttyS0', baudrate = 9600, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE, bytesize=serial.EIGHTBITS, timeout=1)
usuarios = ['+50671665813','+50688263031']#'+50671665813','71665813', ,'+50684797424'] # registro de los numeros telefonicos autorizados
ip = 'u0_a17@192.168.43.11'
GPIO.setwarnings(False)
ultimoSMS = '0'
estadoCompuerta = True#Revisar que la compuerta este cerrada

GPIO.setmode(GPIO.BCM)
GPIO.setup(19, GPIO.OUT)
pwm = GPIO.PWM(19,1000)

###########################################################################################################################################
def check_serial_port():
    last_received_time = time.time()
    GPIO.setup(20, GPIO.OUT)
    GPIO.setup(21, GPIO.OUT)
    pwm.start(0)
    global estadoCompuerta
    
    rx_data = "3333"# Enviar constantemente la senal
    ser.write(str.encode(rx_data))
    time.sleep(0.1)
        
        # Lee datos del puerto serial
    data = ser.readline()
    time.sleep(0.1)
        
    if data == b'3333':
        last_received_time = time.time()  # Actualiza el tiempo de la última recepción
    elif time.time() - last_received_time > 7:
        print("Conexion por cable perdida")
        last_received_time = time.time()  # Reinicia el temporizador para evitar mensajes repetitivos

        
    cod = data.decode('utf-8')
    comando1 = 'cerrar'
    comando2 = 'abrir'
    
    if b'abrir' in data and estadoCompuerta == False:
        print("Abriendo por comando de conexion alambrada")
        GPIO.output(20, GPIO.HIGH)
        GPIO.output(21, GPIO.LOW)
        pwm.ChangeDutyCycle(50)
        time.sleep(2)
        GPIO.output(20, GPIO.LOW)
        pwm.stop()
        estadoCompuerta = True
        
    elif b'cerrar'in data and estadoCompuerta == True:
        print("Cerrando por comando de conexion alambrada")
        GPIO.output(20, GPIO.LOW)
        GPIO.output(21, GPIO.HIGH)
        pwm.ChangeDutyCycle(50)
        time.sleep(1.7)
        GPIO.output(21, GPIO.LOW)
        pwm.stop()
        estadoCompuerta = False
        
###########################################################################################################################################
def read_sms():
        # Ejecutar el comando adb para obtener mensajes SMS de la bandeja de entrada
    result = subprocess.run(['adb', 'shell', 'content', 'query', '--uri', 'content://sms/'], capture_output=True, text=True)
    salida = result.stdout
    
    return salida
###########################################################################################################################################
def ultSMS():
        # Ejecutar el comando adb para obtener mensajes SMS y la cantidad de SMS en bandeja de entrada
    result = subprocess.run(['adb', 'shell', 'content', 'query', '--uri', 'content://sms/'], capture_output=True, text=True)
    salida = result.stdout
    # variable para guardar la cantidad de SMS en bandeja de entrada y que no se repita la accion despues de realizarla una vez
    UltimoSMS = re.search(r'_id=(.*?)\s*,\s*thread_id=', salida)

    if UltimoSMS:
        UltimoSMS = UltimoSMS.group(1)
        print("cantidadSMS=",UltimoSMS)
    else:
        print("No se encontró la parte deseada de cantidad de mensajes en bandeja.")
        UltimoSMS = '0'
    return UltimoSMS

###########################################################################################################################################
def extraer_texto(mensajes): # funcion para extraer el texto del ultimo mensaje recibido de una persona autorizada y lo retorna
    global ultimoSMS
    flag = 0
    #verifica que el ultimo mensaje sea nuevo
    nuevoSMS = re.search(r'_id=(.*?)\s*,\s*thread_id=', mensajes)
    if nuevoSMS:
        nuevoSMS = nuevoSMS.group(1)
        print("cantidadnNuevoSMS=",nuevoSMS)
    else:
        nuevoSMS = '0'
    
    # inicia logica de verificacion
    
    if int(nuevoSMS) > int(ultimoSMS):
        ultimoSMS = nuevoSMS #actualiza la cantidad de SMS en bandeja de entrada
        #Verifica que el ultimo mensaje sea de una persona autorizada
        numero = re.search(r'address=(.*?)\s*,\s*person=', mensajes)
        if numero:
            numero = numero.group(1)
            print("numeroIF",numero)
        else:
            print("No se encontró el numero en el texto")
            numero = '0'
            
        encontro = False
        
        for i, elem in enumerate(usuarios):
            if elem == numero:
            #for i in range(0,len(usuarios))
                encontro = True
                print("Numero autorizado=",numero)
                break
        texto = re.search(r'body=(.*?)\s*,\s*service_center=', mensajes)
                # Extraer y asignar la parte encontrada a una variable
        if texto:
            texto = texto.group(1)                
            print("comando=",texto)
        else:
            print("No se encontró la parte deseada en el texto.")
            texto = '0'
                
        if texto == "abrir" or texto == "cerrar" or "borrar" in texto or "agregar" in texto:
            flag = 1
            print("Comando Valido")
            if not encontro: # entra si termina de recorrer la lista de numeros autorizados 
                for i, elem in enumerate(usuarios):
                    result = subprocess.run(['sudo','ssh', ip, '-p', '8022', 'termux-sms-send', '-n', elem, '"Alerta de numero no Autorizado"'], capture_output=True, text=True)
                    salida = result.stdout
                    print("Mensaje enviado a",elem,"para Alertar de numero no Autorizado")

                time.sleep(3)
                ultimoSMS = ultSMS()
                print("GGG..",ultimoSMS)

            
        elif  flag == 0 and encontro == True: #flag1 es para numero noValido con comando invalido
            result = subprocess.run(['sudo','ssh', '-p', '8022', ip, 'termux-sms-send -n', numero, '"Comando Invalido"'], capture_output=True, text=True)
            salida = result.stdout
            print("Mensaje enviado a",numero,"para indicar Comando Invalido")
            time.sleep(0.5)
            ultimoSMS = ultSMS()
            
    else:
        texto = '0'
    return texto
###########################################################################################################################################
def inicio():#Funcion para estar revisando los mensajes que ingresan en el celular y realizar acciones que solicitan
    
    GPIO.setup(20, GPIO.OUT)
    GPIO.setup(21, GPIO.OUT)
    pwm.start(0)
    global estadoCompuerta
    global ultimoSMS    
    ultimoSMS = ultSMS()
    flag = 0
    
    while True:

        texto = extraer_texto(read_sms())
        
        numcentral = re.search(r'address=(.*?)\s*,\s*person=', read_sms())
        time.sleep(0.1)
        if numcentral:
            numcentral = numcentral.group(1)
            #print("numeroInicio",numcentral)
        else:
            print("No se encontró el numero en el texto")
            numcentral = '0'
        
        if numcentral == "+50671665813":
            #####################################################
            #agregar numeros
            numero = re.search(r'agregar (\d+)', texto)
            
            if numero:
                numero = numero.group(1)
            else:
                #print("No se encontró numero")
                numero = '0'
                
            if numero != '0':
                usuarios.append(numero)
                usuarios.append('+506'+ numero)
                print(numero,"Agragado corectamente")
                flag = 1
                numero = '0'
                
            #####################################################
            #eliminar numeros
            if "borrar" in texto:
                numero = re.search(r'borrar (\d+)', texto)
                if numero:
                    numero = numero.group(1)
                    print("GGnumero",numero)
                else:
                #print("No se encontró numero")
                    numero = '0'
                
            if numero != '0':
                for i, elem in enumerate(usuarios):
                    print("GGeellem",elem)
                    if numero == elem:
                        usuarios.remove(numero)
                        print(numero,"Borrado correctamente")
                        flag = 1
                    elif '+506'+numero == elem:
                        usuarios.remove('+506'+numero)
                        flag = 1
                        print(numero,"Borrado correctamente")
                numero = '0'
        #####################################################
        #controlar compuerttas conexion alambrada
        if texto == "abrir" and estadoCompuerta == False:
            flag = 1
            GPIO.output(20, GPIO.HIGH)
            GPIO.output(21, GPIO.LOW)
            pwm.ChangeDutyCycle(50)
            time.sleep(2)
            GPIO.output(20, GPIO.LOW)
            pwm.stop()
            estadoCompuerta = True
            print("Mensaje recibido, Abrir compuerta")
            result1 = subprocess.run(['sudo','ssh', '-p', '8022', ip, 'termux-sms-send', '-n', numcentral, '"Compuerta abierta"'], capture_output=True, text=True)
            salida = result1.stdout
            print("Mensaje enviado para confirmar comando")
            time.sleep(0.5)
            ultimoSMS = ultSMS()
            
            
        elif texto == "cerrar" and estadoCompuerta == True:
            flag = 1
            GPIO.output(20, GPIO.LOW)
            GPIO.output(21, GPIO.HIGH)
            pwm.ChangeDutyCycle(50)
            time.sleep(1.7)
            GPIO.output(21, GPIO.LOW)
            pwm.stop()
            estadoCompuerta = False
            print("Mensaje recibido, Cerrar compuerta")
            result1 = subprocess.run(['sudo','ssh', '-p', '8022', ip, 'termux-sms-send', '-n', numcentral, '"Compuerta cerrada"'], capture_output=True, text=True)
            salida = result1.stdout
            print("Mensaje enviado para confirmar comando")
            time.sleep(0.5)
            ultimoSMS = ultSMS()
            

###########################################################################################################################################
###########################################################################################################################################


inicio()
