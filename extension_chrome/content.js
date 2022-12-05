function resultados() {
	var preguntas_activo = [3, 5, 7, 9, 13, 20, 26, 27, 35, 37, 41, 43, 46, 48, 51, 61, 67, 74, 75, 77];
	var intervalos_activo = [6,8,10,13,20];

	var preguntas_reflexivo = [10, 16, 18, 19, 28, 31, 32, 34, 36, 39, 42, 44, 49, 55, 58, 63, 65, 69,70,79];
	var intervalos_reflexivo = [11,14,17,18,20];

	var preguntas_teorico = [2, 4, 6, 11, 15, 17, 21, 23, 25, 29, 33, 45, 50, 54, 60, 64, 66, 71, 78, 80];
	var intervalos_teorico = [7,10,14,15,20];

	var preguntas_pragmatico = [1, 8, 12, 14, 22, 24, 30, 38, 40, 47, 52, 53, 56, 57, 59, 62, 68, 72, 73, 76];
	var intervalos_pragmatico = [8,10,14,16,20];
		
	var valoracion_activo = valoracion(preguntas_activo, intervalos_activo);
	var valoracion_reflexivo = valoracion(preguntas_reflexivo, intervalos_reflexivo);
	var valoracion_teorico = valoracion(preguntas_teorico, intervalos_teorico);
	var valoracion_pragmatico = valoracion(preguntas_pragmatico, intervalos_pragmatico);
	alert('Activo: ' + valoracion_activo + '\n' 
		+ 'Reflexivo: ' + valoracion_reflexivo + '\n'
		+ 'Teorico: ' + valoracion_teorico + '\n'
		+ 'Pragmatico: ' + valoracion_pragmatico + '\n');
}

function valoracion(preguntas, intervalos) {
	var total = 0;
	for (var i = 0; i < preguntas.length; i++) {
		if (document.getElementById('q' + getNumberId() + ':' + preguntas[i] + '_answertrue').checked) {
			total++;
		}
	}
	
	var valoracion;
	if (total >= 0 && total <= intervalos[0]) {
		valoracion = 1;
	} else if (total >= intervalos[0] + 1 && total <= intervalos[1]) {
		valoracion = 2;
	} else if (total >= intervalos[1] + 1 && total <= intervalos[2]) {
		valoracion = 3;
	} else if (total >= intervalos[2] + 1 && total <= intervalos[3]) {
		valoracion = 4;
	} else if (total >= intervalos[3] + 1 && total <= intervalos[4]) {
		valoracion = 5;
	}
	
	return valoracion;
}

function getNumberId() {
	var id = $('.que.truefalse.deferredfeedback').first().attr('id');
	return id.split('-')[1];
}


//message listener for background
chrome.runtime.onMessage.addListener(function (request, sender, sendResponse) {
    if(request.command === 'init'){
    	resultados();
    }
    sendResponse({result: "success"});
});