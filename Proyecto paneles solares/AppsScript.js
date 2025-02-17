function doPost(e) {
  // Verifica si se han recibido datos
  if (typeof e !== 'undefined' && typeof e.postData !== 'undefined') {
    var data = JSON.parse(e.postData.contents); // Deserializa los datos JSON

    // Abre la hoja de cálculo por ID
    var sheet = SpreadsheetApp.openById('11pkie5ZGyoCUqdt1WDDz7iG-IGdiddH8I2l44NlPCy8').getActiveSheet();
    
    // Crea un array con los datos recibidos
    var row = [
      new Date(),            // Marca de tiempo
      data.MAXsensor1,        // Dato del MAX6675 sensor 1
      data.MAXsensor2,        // Dato del MAX6675 sensor 2
      data.MAXsensor3,        // Dato del MAX6675 sensor 3
      data.MAXsensor4,        // Dato del MAX6675 sensor 4
      data.NTCsensor1,        // Dato del NTC sensor 1
      data.NTCsensor2,        // Dato del NTC sensor 2
      data.NTCsensor3,        // Dato del NTC sensor 3
      data.DHTsensorTemp,     // Temperatura del sensor DHT
      data.DHTsensorHume,     // Humedad del sensor DHT
      data.DHTsensorIndi,     // Índice de calor del sensor DHT
      data.Irradiancia,       // Dato de irradiancia
      data.VoltajePanel1,     // Voltaje del panel 1
      data.CorrientePanel1,   // Corriente del panel 1
      data.PotenciaPanel1,    // Potencia del panel 1
      data.EnergiaPanel1,     // Energía del panel 1
      data.VoltajePanel2,     // Voltaje del panel 2
      data.CorrientePanel2,   // Corriente del panel 2
      data.PotenciaPanel2,    // Potencia del panel 2
      data.EnergiaPanel2      // Energía del panel 2
    ];
    
    // Inserta los datos en la siguiente fila disponible
    sheet.appendRow(row);
    
    // Retorna un mensaje de éxito
    return ContentService.createTextOutput("Datos recibidos con éxito");
  } else {
    // Si no se recibieron datos, se envía un mensaje de error
    return ContentService.createTextOutput("No se recibieron datos").setMimeType(ContentService.MimeType.TEXT);
  }
}

function doGet(e) {
  // Abre la hoja de cálculo por ID
  var sheet = SpreadsheetApp.openById('11pkie5ZGyoCUqdt1WDDz7iG-IGdiddH8I2l44NlPCy8').getActiveSheet();
  
  // Obtén todos los datos de la hoja de cálculo
  var data = sheet.getDataRange().getValues();
  
  // Prepara un array de objetos JSON
  var jsonData = [];
  
  for (var i = 1; i < data.length; i++) { // Comienza en 1 para omitir encabezados
    var row = data[i];
    jsonData.push({
      timestamp: row[0],          // Marca de tiempo
      MAXsensor1: row[1],
      MAXsensor2: row[2],
      MAXsensor3: row[3],
      MAXsensor4: row[4],
      NTCsensor1: row[5],
      NTCsensor2: row[6],
      NTCsensor3: row[7],
      DHTsensorTemp: row[8],
      DHTsensorHume: row[9],
      DHTsensorIndi: row[10],
      Irradiancia: row[11],
      VoltajePanel1: row[12],
      CorrientePanel1: row[13],
      PotenciaPanel1: row[14],
      EnergiaPanel1: row[15],
      VoltajePanel2: row[16],
      CorrientePanel2: row[17],
      PotenciaPanel2: row[18],
      EnergiaPanel2: row[19]
    });
  }
  
  // Retorna los datos en formato JSON
  return ContentService.createTextOutput(JSON.stringify(jsonData))
         .setMimeType(ContentService.MimeType.JSON);
}
