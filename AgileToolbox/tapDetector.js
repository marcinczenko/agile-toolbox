var touch = {};

function touch_cancel(event) {
	
};

function touch_start(event) {
	touch = {};
	touch.startX = event.touches.item(0).pageX;
	touch.startY = event.touches.item(0).pageY;
	touch.startT = ( new Date() ).getTime();
};

function touch_move(event) {
};

function touch_end(event) {
	touch.endX = event.changedTouches.item(0).pageX;
	touch.endY = event.changedTouches.item(0).pageY; 
	touch.endT = ( new Date() ).getTime();
	// alert("startX:" + touch.startX.toString() + "startY:" + touch.startY.toString() + "startT:" + touch.startT.toString() + "endX:" + touch.endX.toString() + "endY:" + touch.endY.toString() + "endT:" + touch.endT.toString() + "T:" + (touch.endT - touch.startT).toString());
	if(Math.abs(touch.startX-touch.endX)<10 && Math.abs(touch.startY-touch.endY)<10 && Math.abs(touch.startT-touch.endT)<500 &&
	""==window.getSelection()) {
		var myJSONObject = {"tap":"short"};
		var JSONString = (JSON.stringify(myJSONObject));
		var URLString = escape(JSONString);
		var uri = 'QAT:/tap' + '#' + URLString;
		window.location = uri;
	}
};

function myloader() {
    document.addEventListener( 'touchcancel' , touch_cancel , false );
    document.addEventListener( 'touchstart' , touch_start , false );
    document.addEventListener( 'touchmove' , touch_move , false );
    document.addEventListener( 'touchend' , touch_end , false );
};
