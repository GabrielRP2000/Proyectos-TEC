import requests
import matplotlib.pyplot as plt
from datetime import datetime, timedelta
import pytz
import ipywidgets as widgets
from IPython.display import display

# URL de la API de Google Apps Script
url = 'https://script.google.com/macros/s/AKfycbzpWkyD8LbWA110LrHvaZN9pnlGAzWQsqcCUO8JvY-i_fvASVKOoA5QyW4C-4cBpyt7/exec'
response = requests.get(url)

# Procesar los datos JSON si la respuesta fue exitosa
if response.status_code == 200:
    data = response.json()
else:
    print("Error al obtener los datos")

# Convertir los timestamps a objetos datetime con la zona horaria de Costa Rica
utc_zone = pytz.utc
costa_rica_zone = pytz.timezone('America/Costa_Rica')

# Filtrar y extraer fechas disponibles
timestamps = []
for entry in data:
    if entry['timestamp']:
        time_obj = datetime.strptime(entry['timestamp'], '%Y-%m-%dT%H:%M:%S.%fZ')
        time_obj = utc_zone.localize(time_obj)
        local_time = time_obj.astimezone(costa_rica_zone)
        timestamps.append(local_time.date())

# Obtener los días únicos disponibles
dias_disponibles = sorted(list(set(timestamps)))

# Menú para elegir el día
dia_selector = widgets.Dropdown(
    options=dias_disponibles,
    description='Selecciona el día:'
)

# Menú para elegir el tipo de gráfico
grafico_selector = widgets.Dropdown(
    options=['Temperatura vs Irradiancia', 'Potencia vs Irradiancia', 'Potencia vs Temperatura', 'Temperatura Ambiente vs Temperatura'],
    description='Tipo de gráfico:'
)

# Selección de intervalo de horas
hora_inicio_selector = widgets.IntSlider(min=8, max=16, step=1, value=10, description='Hora inicio:')
hora_fin_selector = widgets.IntSlider(min=8, max=16, step=1, value=11, description='Hora fin:')

# Menú para elegir el intervalo de promedio
intervalo_promedio_selector = widgets.Dropdown(
    options=[0, 2, 3, 4],
    description='Promedio (min):'
)

# Función para promediar datos
def promediar_datos(datos, intervalo_min):
    promedios = []
    timestamps_promediados = []
    i = 0
    while i < len(datos):
        end_idx = i
        while end_idx < len(datos) and (datos[end_idx][0] - datos[i][0]).seconds < intervalo_min * 60:
            end_idx += 1
        segmento = datos[i:end_idx]
        if segmento:
            promedio = sum(valor for _, valor in segmento) / len(segmento)
            promedios.append(promedio)
            timestamps_promediados.append(segmento[-1][0])  # Tomar el último timestamp del segmento
        i = end_idx
    return timestamps_promediados, promedios

# Función para filtrar y graficar
def graficar_datos(dia_elegido, tipo_grafico, hora_inicio, hora_fin, intervalo_promedio):
    # Filtrar los datos por el día seleccionado y el intervalo de tiempo
    timestamps_filtered = []
    PotenciaPanel1_filtered = []
    PotenciaPanel2_filtered = []
    EnergiaPanel1_filtered = []
    EnergiaPanel2_filtered = []
    Irradiancia_filtered = []
    NTC2_filtered = []
    NTC3_filtered = []
    TempAmbi_filtered = []
    MAXsensor2_filtered = []
    MAXsensor3_filtered = []

    for entry in data:
        time_obj = datetime.strptime(entry['timestamp'], '%Y-%m-%dT%H:%M:%S.%fZ')
        time_obj = utc_zone.localize(time_obj)
        local_time = time_obj.astimezone(costa_rica_zone)

        # Filtrar por día e intervalo de tiempo
        if local_time.date() == dia_elegido and hora_inicio <= local_time.hour < hora_fin and hora_inicio <= hora_fin:
            timestamps_filtered.append(local_time)
            PotenciaPanel1_filtered.append(float(entry['PotenciaPanel1']))
            PotenciaPanel2_filtered.append(float(entry['PotenciaPanel2']))
            EnergiaPanel1_filtered.append(float(entry['EnergiaPanel1']))
            EnergiaPanel2_filtered.append(float(entry['EnergiaPanel2']))
            Irradiancia_filtered.append(float(entry['Irradiancia']))
            NTC2_filtered.append(float(entry['NTCsensor2']))
            NTC3_filtered.append(float(entry['NTCsensor3']))
            TempAmbi_filtered.append(float(entry['DHTsensorTemp']))
            MAXsensor2_filtered.append(float(entry['MAXsensor2']))
            MAXsensor3_filtered.append(float(entry['MAXsensor3']))

    # Crear segmentos para el promedio
    if intervalo_promedio > 0:
        timestamps_filtered, PotenciaPanel1_filtered = promediar_datos(list(zip(timestamps_filtered, PotenciaPanel1_filtered)), intervalo_promedio)
        _, PotenciaPanel2_filtered = promediar_datos(list(zip(timestamps_filtered, PotenciaPanel2_filtered)), intervalo_promedio)
        _, EnergiaPanel1_filtered = promediar_datos(list(zip(timestamps_filtered, EnergiaPanel1_filtered)), intervalo_promedio)
        _, EnergiaPanel2_filtered = promediar_datos(list(zip(timestamps_filtered, EnergiaPanel2_filtered)), intervalo_promedio)
        _, Irradiancia_filtered = promediar_datos(list(zip(timestamps_filtered, Irradiancia_filtered)), intervalo_promedio)
        _, NTC2_filtered = promediar_datos(list(zip(timestamps_filtered, NTC2_filtered)), intervalo_promedio)
        _, NTC3_filtered = promediar_datos(list(zip(timestamps_filtered, NTC3_filtered)), intervalo_promedio)
        _, TempAmbi_filtered = promediar_datos(list(zip(timestamps_filtered, TempAmbi_filtered)), intervalo_promedio)
        _, MAXsensor2_filtered = promediar_datos(list(zip(timestamps_filtered, MAXsensor2_filtered)), intervalo_promedio)
        _, MAXsensor3_filtered = promediar_datos(list(zip(timestamps_filtered, MAXsensor3_filtered)), intervalo_promedio)

    # Asegurar que los datos tengan la misma longitud
    min_length = min(len(timestamps_filtered), len(PotenciaPanel1_filtered), len(PotenciaPanel2_filtered), len(EnergiaPanel1_filtered), len(EnergiaPanel2_filtered),
                     len(Irradiancia_filtered), len(NTC2_filtered), len(NTC3_filtered),
                     len(TempAmbi_filtered), len(MAXsensor2_filtered), len(MAXsensor3_filtered))

    timestamps_filtered = timestamps_filtered[:min_length]
    PotenciaPanel1_filtered = PotenciaPanel1_filtered[:min_length]
    PotenciaPanel2_filtered = PotenciaPanel2_filtered[:min_length]
    EnergiaPanel1_filtered = EnergiaPanel1_filtered[:min_length]
    EnergiaPanel2_filtered = EnergiaPanel2_filtered[:min_length]
    Irradiancia_filtered = Irradiancia_filtered[:min_length]
    NTC2_filtered = NTC2_filtered[:min_length]
    NTC3_filtered = NTC3_filtered[:min_length]
    TempAmbi_filtered = TempAmbi_filtered[:min_length]
    MAXsensor2_filtered = MAXsensor2_filtered[:min_length]
    MAXsensor3_filtered = MAXsensor3_filtered[:min_length]




    # Crear la figura para el gráfico
    fig, ax1 = plt.subplots(figsize=(10, 6))

    if tipo_grafico == 'Temperatura vs Irradiancia':
        ax1.set_xlabel('Tiempo')
        ax1.set_ylabel('Temperatura (°C)', color='k')
        ax1.plot(timestamps_filtered, NTC2_filtered, label='NTC panel sin enfriamiento', color='r')
        ax1.plot(timestamps_filtered, NTC3_filtered, label='NTC panel con enfriamiento', color='orange')
        ax1.legend(loc='lower left')
        ax2 = ax1.twinx()
        ax2.set_ylabel('Irradiancia (W/m²)', color='k')
        ax2.plot(timestamps_filtered, Irradiancia_filtered, label='Irradiancia', color='b', marker='', linestyle='--')
        ax2.legend(loc='upper right')

    elif tipo_grafico == 'Potencia vs Irradiancia':
        ax1.set_xlabel('Tiempo')
        ax1.set_ylabel('Potencia (mW)', color='k')
        ax1.plot(timestamps_filtered, PotenciaPanel1_filtered, label='Potencia sin enfriamiento', color='g')
        ax1.plot(timestamps_filtered, PotenciaPanel2_filtered, label='Potencia con enfriamiento', color='b')
        ax1.legend(loc='lower left')
        ax2 = ax1.twinx()
        ax2.set_ylabel('Irradiancia (W/m²)', color='k')
        ax2.plot(timestamps_filtered, Irradiancia_filtered, label='Irradiancia', color='r', linestyle='--')
        ax2.legend(loc='upper right')

    elif tipo_grafico == 'Potencia vs Temperatura':
        ax1.set_xlabel('Tiempo')
        ax1.set_ylabel('Potencia (mW)', color='k')
        ax1.plot(timestamps_filtered, PotenciaPanel1_filtered, label='Potencia sin enfriamiento', color='g')
        ax1.plot(timestamps_filtered, PotenciaPanel2_filtered, label='Potencia con enfriamiento', color='b')
        ax1.legend(loc='lower left')
        ax2 = ax1.twinx()
        ax2.set_ylabel('Temperatura (°C)', color='k')
        ax2.plot(timestamps_filtered, NTC2_filtered, label='NTC panel sin enfriamiento', color='r', linestyle='--')
        ax2.plot(timestamps_filtered, NTC3_filtered, label='NTC panel con enfriamiento', color='orange', linestyle='--')
        ax2.legend(loc='upper right')
    elif tipo_grafico == 'Temperatura Ambiente vs Temperatura':
        # Graficar cada sensor
        #plt.plot(timestamps_filtered, MAXsensor1, label='Sol directo', marker='')
        plt.xlabel('Tiempo')
        plt.plot(timestamps_filtered, MAXsensor2_filtered, label='Tipo k penel sin enfriamiento', marker='')
        plt.plot(timestamps_filtered, MAXsensor3_filtered, label='Tipo k penel sin enfriamiento', marker='')
        plt.plot(timestamps_filtered, NTC2_filtered, label='NTC panel sin enfriamiento', marker='')
        #plt.plot(timestamps_filtered, NTC3_filtered, label='Superior panel con enfriamiento', marker='', color='orange')
        plt.plot(timestamps_filtered, TempAmbi_filtered, label='Temperatura en sombra', marker='', color='r')

        # Etiquetas y título
        plt.ylabel('Temperatura (°C)')
        plt.legend(loc='upper left')

    # Rotar las etiquetas
    plt.xticks(rotation=45)
    plt.title(f'{tipo_grafico} - {dia_elegido}')#- promedio cada {intervalo_promedio} minutos')
    plt.grid(True)
    plt.tight_layout()
    plt.show()

import pandas as pd

# Constantes (por ejemplo, área del panel en metros cuadrados)
AREA_PANEL = 0.022275  # Cambia este valor según el área real de tus paneles, mi caso 0.135 m* 0.165 m = 0.022275 m^2

# Función para calcular la energía y eficiencia
def calcular_energia_y_eficiencia(dia_elegido, hora_inicio, hora_fin):
    # Filtrar los datos por el día seleccionado y el intervalo de tiempo
    timestamps_filtered = []
    PotenciaPanel1_filtered = []
    PotenciaPanel2_filtered = []
    Irradiancia_filtered = []
    EnergiaPanel1_filtered = []
    EnergiaPanel2_filtered = []

    for entry in data:
        time_obj = datetime.strptime(entry['timestamp'], '%Y-%m-%dT%H:%M:%S.%fZ')
        time_obj = utc_zone.localize(time_obj)
        local_time = time_obj.astimezone(costa_rica_zone)

        # Filtrar por día e intervalo de tiempo
        if local_time.date() == dia_elegido and hora_inicio <= local_time.hour < hora_fin:
            timestamps_filtered.append(local_time)
            PotenciaPanel1_filtered.append(float(entry['PotenciaPanel1']))
            PotenciaPanel2_filtered.append(float(entry['PotenciaPanel2']))
            EnergiaPanel1_filtered.append(float(entry['EnergiaPanel1']))
            EnergiaPanel2_filtered.append(float(entry['EnergiaPanel2']))
            Irradiancia_filtered.append(float(entry['Irradiancia']))

    # Asegurar que los datos tengan la misma longitud
    min_length = min(len(timestamps_filtered), len(PotenciaPanel1_filtered), len(PotenciaPanel2_filtered), len(EnergiaPanel1_filtered), len(EnergiaPanel2_filtered),
                     len(Irradiancia_filtered))

    timestamps_filtered = timestamps_filtered[:min_length]
    PotenciaPanel1_filtered = PotenciaPanel1_filtered[:min_length]
    PotenciaPanel2_filtered = PotenciaPanel2_filtered[:min_length]
    EnergiaPanel1_filtered = EnergiaPanel1_filtered[:min_length]
    EnergiaPanel2_filtered = EnergiaPanel2_filtered[:min_length]
    Irradiancia_filtered = Irradiancia_filtered[:min_length]


    # Convertir timestamps a diferencias de tiempo en segundos
    tiempo_segundos = [(timestamps_filtered[i+1] - timestamps_filtered[i]).total_seconds() for i in range(len(timestamps_filtered) - 1)]
    tiempo_segundos.append(tiempo_segundos[-1])  # Repetimos el último valor para mantener misma longitud
    #print(f"Tiempooooo: {tiempo_segundos[len(tiempo_segundos)-5]}")
    # Calcular la energía de cada panel en mJ
    energia_panel1 = sum(p * t for p, t in zip(PotenciaPanel1_filtered, tiempo_segundos))/1000  # mJ a J
    energia_panel2 = sum(p * t for p, t in zip(PotenciaPanel2_filtered, tiempo_segundos))/1000  # mJ a J
    energia_panel1 = energia_panel1/3.600 # pasar de J a mWh
    energia_panel2 = energia_panel2/3.600 # pasar de J a mWh

    energiaINA_panel1 = EnergiaPanel1_filtered[-1]-EnergiaPanel1_filtered[0]
    energiaINA_panel2 = EnergiaPanel2_filtered[-1]-EnergiaPanel2_filtered[0]
    energiaINA_panel1 = energiaINA_panel1/3.600 # pasar de J a mWh
    energiaINA_panel2 = energiaINA_panel2/3.600 # pasar de J a mWh

    # Calcular la potencia incidente (W/m² a W) y la energía incidente total sobre el área del panel
    potencia_incidente = [(irradiancia) * AREA_PANEL  for irradiancia in Irradiancia_filtered]
    #print(f"Tiempooooo: {potencia_incidente[len(potencia_incidente)-5]}")
    energia_incidente = sum(pi * t for pi, t in zip(potencia_incidente, tiempo_segundos))  # en J
    energia_incidente = energia_incidente/3.600 # pasar de J a mWh
    # Eficiencia de cada panel
    eficiencia_panel1 = (energia_panel1 / energia_incidente) * 100 if energia_incidente > 0 else 0
    eficiencia_panel2 = (energia_panel2 / energia_incidente) * 100 if energia_incidente > 0 else 0

    # Crear una tabla con los resultados
    print(" ")
    print(f"Tabla de Energias y eficiencia del {dia_elegido} de las {hora_inicio} a {hora_fin} horas  ")
    tabla = pd.DataFrame({
        "Panel": ["Panel Sin Enfriamiento", "Panel Con Enfriamiento"],
        "Energía Generada (mWh)": [energia_panel1, energia_panel2],
        "Energía datos INA (mWh)": [energiaINA_panel1, energiaINA_panel2],
        "Energía Incidente (mWh)": [energia_incidente, energia_incidente],
        "Eficiencia (%)": [eficiencia_panel1, eficiencia_panel2]
    })

    return tabla

# Función para ejecutar el gráfico
def mostrar_grafico(_):
    graficar_datos(dia_selector.value, grafico_selector.value, hora_inicio_selector.value, hora_fin_selector.value, intervalo_promedio_selector.value)

# Función para ejecutar Tabla
def mostrar_tabla(_):
    tabla_energia_eficiencia = calcular_energia_y_eficiencia(dia_selector.value, hora_inicio_selector.value, hora_fin_selector.value)
    display(tabla_energia_eficiencia)

# Botón para generar el gráfico
boton_graficar = widgets.Button(description="Generar gráfico")
boton_graficar.on_click(mostrar_grafico)

# Botón para generar Tabla
boton_tabla = widgets.Button(description="Generar Tabla")
boton_tabla.on_click(mostrar_tabla)

print("Para el botón Generar Gráfico primero seleccione la fecha, el tipo de gráfico, el rango de horas y si desea promediar los datos por minutos luego presione el boton Generar Gráfico")
print("Para el botón Generar tabla primero seleccione la fecha y el rango de horas en el que desea observar la tabla de Energias y Eficiencia luego presione el boton Generar tabla")
# Mostrar los menús interactivos
display(dia_selector, grafico_selector, hora_inicio_selector, hora_fin_selector, intervalo_promedio_selector, boton_graficar,boton_tabla)


