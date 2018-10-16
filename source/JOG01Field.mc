using Toybox.Application as App;
        using Toybox.WatchUi as Ui;
        using Toybox.Graphics as Graphics;
        using Toybox.System as System;

//! @author Konrad Paumann
class JOG01Field extends App.AppBase {

    function getInitialView() {
        var view = new JOG01View();
        return [ view ];
    }
}

//! A DataField that shows some infos.
//!
//! @author Konrad Paumann
class JOG01View extends Ui.DataField {

      hidden const CENTER = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
    hidden const HEADER_FONT = Graphics.FONT_SYSTEM_XTINY;
    hidden const VALUE_FONT = Graphics.FONT_NUMBER_MEDIUM;
    hidden const ZERO_TIME = "0:00";
    hidden const ZERO_DISTANCE = "0.00";
    
    hidden var kmOrMileInMeters = 1000;
    hidden var is24Hour = true;
    hidden var distanceUnits = System.UNIT_METRIC;
    hidden var textColor = Graphics.COLOR_BLACK;
    hidden var inverseTextColor = Graphics.COLOR_WHITE;
    hidden var backgroundColor = Graphics.COLOR_WHITE;
    hidden var inverseBackgroundColor = Graphics.COLOR_BLACK;
    hidden var inactiveGpsBackground = Graphics.COLOR_LT_GRAY;
    hidden var batteryBackground = Graphics.COLOR_WHITE;
    hidden var batteryColor1 = Graphics.COLOR_GREEN;
    hidden var hrColor = Graphics.COLOR_RED;
    hidden var lapColor = Graphics.COLOR_DK_BLUE;
    hidden var headerColor = Graphics.COLOR_DK_GRAY;
        
    hidden var paceStr, avgPaceStr, hrStr, distanceStr, durationStr,lapPaceStr;
    
    hidden var paceData = new DataQueue(10);
    hidden var paceData30 = new DataQueue(30);
    hidden var paceData3 = new DataQueue(3);

    hidden var doUpdates = 0;
	
	hidden var speed = 0;
    hidden var avgSpeed= 0;
    hidden var maxSpeed= 0;
    hidden var hr = 0;
    hidden var avghr = 0;
    hidden var maxhr = 0;
    hidden var distance = 0;
    hidden var elapsedTime = 0;
    hidden var gpsSignal = 0;
    
    hidden var currentCadence = 0;
    hidden var averageCadence = 0;
    hidden var maxCadence = 0;
    
    
     //lap
    hidden var compteurLap = 0;
    hidden var distLap=0;
    hidden var distLapStr;
    hidden var durationLap;
    hidden var timeLap=0;
    hidden var timeLapTmp=0;
    hidden var distLapCourant=0;
    hidden var timeLapCourant=0;
    hidden var speedLap = 0;
    hidden var speedLapCourant = 0;
    hidden var timeLapStr=ZERO_TIME;
    hidden var distLapOnLap = 0;
    
    //
    hidden var ascension=0;
    hidden var switchData = 0;
    
    hidden var hasBackgroundColorOption = false;
    hidden var cpt = 0;
    hidden var afficheSpeed = true;
    
    function initialize() {
        DataField.initialize();
    }
    
    function onTimerLap(){
    	compteurLap ++;
    	speedLapCourant = speedLap;
    	distLapOnLap = distLap;
        distLapCourant = distance != null ? distance : 0;
        timeLapTmp = elapsedTime - timeLapCourant; 
        timeLapCourant = elapsedTime != null ? elapsedTime : 0;
        if (timeLapTmp != null && timeLapTmp > 0) {
 			timeLapStr = msToTime(timeLapTmp,0);
        } else {
            timeLapStr = ZERO_TIME;
        } 
        
        if (timeLap != null && timeLap > 0) {
        	if (timeLap < 4000){
        		if (switchData == 0){
        			switchData = 1;
        		}else{
        			switchData = 0;
        		}
        	}
        } 
        
        

    }

    //! The given info object contains all the current workout
    function compute(info) {
    	cpt = cpt + 1;
    	
    	if (cpt == 1){
    		cpt = 0;
    		if (afficheSpeed){
    			afficheSpeed = false;
    		}else{
    			afficheSpeed = true;
    		}
    	}
    
        if (info.currentSpeed != null) {
            paceData.add(info.currentSpeed);
            paceData30.add(info.currentSpeed);
            paceData3.add(info.currentSpeed);
        } else {
            paceData.reset();
            paceData30.reset();
            paceData3.reset;
        }
        
        speed = info.currentSpeed != null ? info.currentSpeed : 0;
        avgSpeed = info.averageSpeed != null ? info.averageSpeed : 0;
        maxSpeed = info.maxSpeed != null ? info.maxSpeed : 0;
        elapsedTime = info.timerTime != null ? info.timerTime : 0;        
        hr = info.currentHeartRate != null ? info.currentHeartRate : 0;
        avghr = info.averageHeartRate != null ? info.averageHeartRate : 0;
        maxhr = info.maxHeartRate != null ? info.maxHeartRate : 0;
        distance = info.elapsedDistance != null ? info.elapsedDistance : 0;
        gpsSignal = info.currentLocationAccuracy != null ? info.currentLocationAccuracy : 0;
        
		speed = speed * 3.6;

        maxCadence = info.maxCadence != null ? info.maxCadence : 0;
        averageCadence = info.averageCadence != null ? info.averageCadence : 0;
        currentCadence = info.currentCadence != null ? info.currentCadence : 0;
        
        
        ascension = info.totalAscent != null ? info.totalAscent : 0;
    
        if (compteurLap == 0){
            speedLap = avgSpeed;
            distLap=distance;
            timeLap=elapsedTime;
        }else{
            if (elapsedTime != null &&  distance != null){
                distLap = distance - distLapCourant;
                timeLap =  elapsedTime - timeLapCourant;
                
                if (distLap>0 && timeLap>0){
                    var timeLapSecond = timeLap / 1000;
                    if (timeLapSecond != null && timeLapSecond > 0.2){
                        speedLap = distLap / timeLapSecond;
                    }else{
                        speedLap = 0;
                    }
                   
                }else{
                    speedLap = 0;
                }
            }
        }

    }
    
    function onLayout(dc) {
        setDeviceSettingsDependentVariables();
        //onUpdate(dc);
    }
    
    function onShow() {
        doUpdates = true;
        return true;
    }
    
    function onHide() {
        doUpdates = false;
    }
    
    function onUpdate(dc) {
        if(doUpdates == false) {
            return;
        }
        
        setColors();
        // reset background
        dc.setColor(backgroundColor, backgroundColor);
        dc.fillRectangle(0, 0, 218, 218);
        
        drawValues(dc);
    }

    function setDeviceSettingsDependentVariables() {
        hasBackgroundColorOption = (self has :getBackgroundColor);
    }
    
    function setColors() {
        if (hasBackgroundColorOption) {
            backgroundColor = getBackgroundColor();
            //TODO:pour les tests
            //backgroundColor = Graphics.COLOR_BLACK;
            textColor = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
            inverseTextColor = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_WHITE : Graphics.COLOR_WHITE;
            inverseBackgroundColor = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_DK_GRAY: Graphics.COLOR_BLACK;
            hrColor = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
            headerColor = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_LT_GRAY: Graphics.COLOR_DK_GRAY;
            batteryColor1 = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_BLUE : Graphics.COLOR_DK_GREEN;
            lapColor = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_GREEN : Graphics.COLOR_DK_BLUE;
        }
    }
    

        
    function drawValues(dc) {
    
        //time
        var clockTime = System.getClockTime();
        var time = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%.2d")]);
          
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0,0,218,20);
        dc.setColor(inverseTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(106, 10, Graphics.FONT_TINY, time, CENTER);
        var battery = System.getSystemStats().battery;
        dc.drawText(147, 10, Graphics.FONT_TINY,battery.format("%d"), CENTER);
 
        var computeAvgSpeed = computeAverageSpeed(paceData);
       
        
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        
        //timeLap
        var durationLap;
        if (timeLap != null && timeLap > 0) {
     		durationLap=msToTime(timeLap,0);
        } else {
            durationLap = ZERO_TIME;
        } 

		var avgSpeedKmh = avgSpeed * 3.6;
        if (switchData == 0){
            if (afficheSpeed){
                dc.drawText(dc.getWidth() /2+2 , 50, Graphics.FONT_NUMBER_THAI_HOT,getMinutesPerKmOrMile(speed / 3.6) , CENTER);//speedLisse.format("%.1f")//speed.format("%.1f")
            }else{
                dc.drawText(dc.getWidth() /2+2 , 50, Graphics.FONT_NUMBER_THAI_HOT, avgSpeedKmh.format("%.1f"), CENTER);//speedLisse.format("%.1f")//speed.format("%.1f")
            }
        }else{
            dc.drawText(dc.getWidth() /2+5 , 50, Graphics.FONT_NUMBER_THAI_HOT,getMinutesPerKmOrMile(speedLap / 3.6) , CENTER);
        }

		

        //duration
        var duration;
        var timeEtude = elapsedTime;
        //timeEtude = 55801800;
        if (timeEtude != null && timeEtude > 0) {
            duration = msToTime(timeEtude,0);
        } else {
            duration = ZERO_TIME;
        } 
		
		dc.drawText(200, 163, HEADER_FONT, "km", CENTER);
		
		if (switchData == 0){
		    dc.drawText(dc.getWidth()/2, 180, Graphics.FONT_NUMBER_HOT, convertDistance(distance), CENTER);//convertDistance(distance)
			dc.drawText(dc.getWidth()/2, 121, Graphics.FONT_NUMBER_HOT, duration, CENTER);//duration      	
		}else{
		    dc.drawText(dc.getWidth()/2, 180, Graphics.FONT_NUMBER_HOT, convertDistance(distLap), CENTER);//convertDistance(distance)
			dc.drawText(dc.getWidth()/2, 121, Graphics.FONT_NUMBER_HOT, durationLap, CENTER);//duration      	
		}

        //tendance speed
        if (avgSpeed>speedLap){
        	dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            drawBlocSpeed(dc,avgSpeed,speedLap,0);
        }else if (speedLap>avgSpeed){
         	dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            drawBlocSpeed(dc,speedLap,avgSpeed,0);
        }
		    
		if (computeAvgSpeed>speedLap && speedLap>0){
        	dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            drawBlocSpeed(dc,computeAvgSpeed,speedLap,120);
        }else if (speedLap>computeAvgSpeed && speedLap>0){
         	dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
         	drawBlocSpeed(dc,speedLap,computeAvgSpeed,120);
        }

        //GRID
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0,80, dc.getWidth(), 80);
        dc.drawLine(0,81, dc.getWidth(), 81);
        dc.drawLine(0,150, dc.getWidth(), 150);
        dc.drawLine(0,151, dc.getWidth(), 151);
        
  
                
        // gps 
        if (gpsSignal <= 2) {
           dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
           //dc.drawText(22, 152, HEADER_FONT, "GPS", CENTER);
        } 
      
        if (hr>=100 && hr<150){
        	dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);	
        	dc.fillRectangle(0,210,240,30);
        }else if (hr>=150 && hr<160){
         	dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
         	dc.fillRectangle(0,210,240,30);
        }else if (hr>=160 && hr<170){
         	dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
         	dc.fillRectangle(0,210,240,30);
        }else if (hr>=170 && hr<180){
         	dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
         	dc.fillRectangle(0,210,240,30);
        }else if (hr>=180){
         	dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
         	dc.fillRectangle(0,210,240,20);
        }
        
                
        //HR
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2 ,223, Graphics.FONT_NUMBER_MILD, hr.format("%d"), CENTER);// hr.format("%d")
        
    }


    function drawBlocSpeed(dc, speed1, speed2,decalage){
        if (getDiffSpeed(speed1,speed2)>30){
           dc.fillRectangle(0+decalage,80,15,15);
        }

        if (getDiffSpeed(speed1,speed2)<30){
            dc.fillRectangle(0+decalage,80,37,15);
        }

        if (getDiffSpeed(speed1,speed2)<20){
            dc.fillRectangle(40+decalage,80,37,15);
        }

        if (getDiffSpeed(speed1,speed2)<10){
            dc.fillRectangle(80+decalage,80,37,15);
        }
    }
    

    function computeAverageSpeed(tableau) {
        var size = 0;
        var data = tableau.getData();
        var sumOfData = 0.0;
        for (var i = 0; i < data.size(); i++) {
            if (data[i] != null) {
                sumOfData = sumOfData + data[i];
                size++;
            }
        }
        if (sumOfData > 0) {
            return sumOfData / size;
        }
        return 0.0;
    }
    
   
    
	function msToTime(ms,isHour) {
    	var seconds = (ms / 1000) % 60;
    	var minutes = (ms / 60000) % 60;
    	var hours = ms / 3600000;
    	
    	if (isHour){
    		if (hours>0){
    			return hours.format("%d");
    		}else{
    			return "";
    		}
    	}else{
    		if (minutes < 10){
    			return Lang.format("$1$:$2$", [minutes.format("%d"), seconds.format("%02d")]);
    		}
    		else if (minutes >10 && hours ==""){
    			return Lang.format("$1$:$2$", [minutes.format("%02d"), seconds.format("%02d")]);
    		}else{
    			return Lang.format("$1$:$2$:$3$", [hours.format("%02d"),minutes.format("%02d"), seconds.format("%02d")]);
    		}	
    	} 
    }
    
     function convertDistance(metres) {
    	var result;
    	
    	if( metres == null ) {
    		result = 0;
    	} else {
	   	result = metres / 1000.0;
	   }
    	
    	return Lang.format("$1$", [result.format("%.2f")]);
    }
    
    function getMinutesPerKmOrMile(speedMetersPerSecond) {
        if (speedMetersPerSecond != null && speedMetersPerSecond > 0.2) {
            var metersPerMinute = speedMetersPerSecond * 60.0;
            var minutesPerKmOrMilesDecimal = kmOrMileInMeters / metersPerMinute;
            var minutesPerKmOrMilesFloor = minutesPerKmOrMilesDecimal.toNumber();
            var seconds = (minutesPerKmOrMilesDecimal - minutesPerKmOrMilesFloor) * 60;
            return minutesPerKmOrMilesDecimal.format("%2d") + ":" + seconds.format("%02d");
        }
        return ZERO_TIME;
    }

    function getDiffSpeed(speedMetersPerSecond1,speedMetersPerSecond2) {
        //speedMetersPerSecond1 must be >= speedMetersPerSecond2
        var secondesPerKmOrMilesDecimal1 = 0;
        if (speedMetersPerSecond1 != null && speedMetersPerSecond1 > 0.2) {
            var metersPerMinute1 = speedMetersPerSecond1 * 60.0;
            var minutesPerKmOrMilesDecimal1 = kmOrMileInMeters / metersPerMinute1;
            secondesPerKmOrMilesDecimal1 =  minutesPerKmOrMilesDecimal1 * 60;
        }

        var secondesPerKmOrMilesDecimal2 = 0;
        if (speedMetersPerSecond2 != null && speedMetersPerSecond2 > 0.2) {
            var metersPerMinute2 = speedMetersPerSecond2 * 60.0;
            var minutesPerKmOrMilesDecimal2 = kmOrMileInMeters / metersPerMinute2;
            secondesPerKmOrMilesDecimal2 =  minutesPerKmOrMilesDecimal2 * 60;
        }

        if (secondesPerKmOrMilesDecimal1>0 &&  secondesPerKmOrMilesDecimal2>0){
            return secondesPerKmOrMilesDecimal2 - secondesPerKmOrMilesDecimal1;
        }else{
            return 0;
        }
    }

}

//! A circular queue implementation.
//! @author Konrad Paumann
class DataQueue {

    //! the data array.
    hidden var data;
    hidden var maxSize = 0;
    hidden var pos = 0;

    //! precondition: size has to be >= 2
    function initialize(arraySize) {
        data = new[arraySize];
        maxSize = arraySize;
    }
    
    //! Add an element to the queue.
    function add(element) {
        data[pos] = element;
        pos = (pos + 1) % maxSize;
    }
    
    //! Reset the queue to its initial state.
    function reset() {
        for (var i = 0; i < data.size(); i++) {
            data[i] = null;
        }
        pos = 0;
    }
    
    //! Get the underlying data array.
    function getData() {
        return data;
    }
}